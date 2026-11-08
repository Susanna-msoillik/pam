from datetime import datetime, timezone

from fastapi import APIRouter, Depends, Query, Response
from sqlalchemy import func, select, text
from sqlalchemy.orm import Session

from .auth import require_auth
from .db import get_db
from .errors import ApiError, json_response, not_found
from .models import Booking
from .routes import ResourceId, find_route, route_json
from .schemas import BookingBody, BookingUpdateBody

router = APIRouter()


def booking_json(booking, include_route=True):
    value = {"id": booking.id, "routeId": booking.route_id,
             "passengerId": booking.passenger_id, "seats": booking.seats,
             "status": booking.status, "createdAt": booking.created_at}
    if include_route:
        value["route"] = route_json(booking.route)
    return value


def find_booking(db, booking_id, user_id):
    booking = db.get(Booking, booking_id)
    if booking is None or booking.passenger_id != user_id:
        raise not_found("Бронирование не найдено")
    return booking


@router.get("/bookings")
def list_bookings(page: int = Query(1, ge=1), limit: int = Query(20, ge=1, le=100), user_id: int = Depends(require_auth), db: Session = Depends(get_db)):
    query = select(Booking).where(Booking.passenger_id == user_id)
    total = db.scalar(select(func.count()).select_from(query.subquery()))
    items = db.scalars(query.order_by(Booking.created_at.desc(), Booking.id.desc()).offset((page-1)*limit).limit(limit)).all()
    return json_response({"items": [booking_json(b) for b in items], "page": page, "limit": limit, "total": total})


@router.get("/routes/{route_id}/bookings")
def route_bookings(route_id: ResourceId, user_id: int = Depends(require_auth), db: Session = Depends(get_db)):
    find_route(db, route_id)
    items = db.scalars(select(Booking).where(Booking.route_id == route_id, Booking.status == "active").order_by(Booking.id)).all()
    # All active seat reservations; never cut this list into pages.
    return json_response({"items": [booking_json(b, False) for b in items]})


@router.post("/bookings")
def create_booking(body: BookingBody, user_id: int = Depends(require_auth), db: Session = Depends(get_db)):
    # SQLite serialises the capacity check and insert in this transaction.
    db.execute(text("BEGIN IMMEDIATE"))
    route = find_route(db, body.route_id)
    if route.driver_id == user_id:
        raise ApiError(400, "OWN_ROUTE", "Нельзя бронировать свою поездку")
    own = db.scalar(select(Booking).where(Booking.route_id == route.id, Booking.passenger_id == user_id, Booking.status == "active"))
    if own is not None:
        return json_response(booking_json(own))
    if datetime.fromisoformat(route.departure_at) <= datetime.now(timezone.utc):
        raise ApiError(409, "DEPARTED", "Поездка уже началась")
    occupied = db.scalar(select(func.coalesce(func.sum(Booking.seats), 0)).where(Booking.route_id == route.id, Booking.status == "active"))
    if body.seats > route.seats_total - occupied:
        raise ApiError(409, "NO_SEATS", "Недостаточно свободных мест")
    booking = Booking(route_id=route.id, passenger_id=user_id, seats=body.seats)
    db.add(booking)
    db.commit()
    return json_response(booking_json(booking), 201)


@router.get("/bookings/{booking_id}")
def get_booking(booking_id: ResourceId, user_id: int = Depends(require_auth), db: Session = Depends(get_db)):
    return json_response(booking_json(find_booking(db, booking_id, user_id)))


@router.put("/bookings/{booking_id}")
def cancel_booking(booking_id: ResourceId, body: BookingUpdateBody, user_id: int = Depends(require_auth), db: Session = Depends(get_db)):
    booking = find_booking(db, booking_id, user_id)
    booking.status = body.status
    db.commit()
    return json_response(booking_json(booking))


@router.delete("/bookings/{booking_id}")
def delete_booking(booking_id: ResourceId, user_id: int = Depends(require_auth), db: Session = Depends(get_db)):
    booking = find_booking(db, booking_id, user_id)
    db.delete(booking)
    db.commit()
    return Response(status_code=204)
