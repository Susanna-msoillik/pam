from datetime import date, datetime, time, timedelta, timezone
from typing import Annotated

from fastapi import APIRouter, Depends, Path, Query, Response
from sqlalchemy import func, select, text
from sqlalchemy.orm import Session

from .auth import require_auth
from .db import get_db
from .errors import ApiError, json_response, not_found
from .models import Booking, Route
from .schemas import LOCAL_TZ, RouteBody

router = APIRouter()
ResourceId = Annotated[int, Path(gt=0, lt=2**63)]


def route_json(route):
    return {
        "id": route.id, "driverId": route.driver_id,
        "driverName": route.driver.name,
        "fromCity": route.from_city, "toCity": route.to_city,
        "departureAt": route.departure_at, "seatsTotal": route.seats_total,
        "price": route.price, "deleted": route.deleted,
    }


def find_route(db, route_id, user_id=None):
    route = db.get(Route, route_id)
    if route is None or route.deleted or (user_id is not None and route.driver_id != user_id):
        raise not_found("Поездка не найдена")
    return route


def require_no_bookings(db, route_id):
    if db.scalar(select(Booking.id).where(Booking.route_id == route_id, Booking.status == "active").limit(1)):
        raise ApiError(409, "ACTIVE_BOOKINGS", "Сначала отмените активные брони")


@router.get("/routes")
def list_routes(
    page: int = Query(1, ge=1), limit: int = Query(20, ge=1, le=100),
    from_city: str | None = Query(None, alias="from"),
    to_city: str | None = Query(None, alias="to"),
    day: date | None = Query(None, alias="date"),
    driver_id: int | None = Query(None, alias="driverId", gt=0, lt=2**63),
    user_id: int = Depends(require_auth), db: Session = Depends(get_db),
):
    query = select(Route).where(Route.deleted.is_(False))
    if from_city:
        query = query.where(func.casefold(Route.from_city).contains(from_city.strip().casefold(), autoescape=True))
    if to_city:
        query = query.where(func.casefold(Route.to_city).contains(to_city.strip().casefold(), autoescape=True))
    if driver_id is not None:
        query = query.where(Route.driver_id == driver_id)
    if day is not None:
        start = datetime.combine(day, time.min, LOCAL_TZ)
        end = datetime.combine(day + timedelta(days=1), time.min, LOCAL_TZ)
        query = query.where(
            Route.departure_at >= start.astimezone(timezone.utc).isoformat(),
            Route.departure_at < end.astimezone(timezone.utc).isoformat(),
        )
    total = db.scalar(select(func.count()).select_from(query.subquery()))
    items = db.scalars(query.order_by(Route.departure_at, Route.id).offset((page-1)*limit).limit(limit)).all()
    return json_response({"items": [route_json(r) for r in items], "page": page, "limit": limit, "total": total})


@router.post("/routes")
def create_route(body: RouteBody, user_id: int = Depends(require_auth), db: Session = Depends(get_db)):
    fields = body.model_dump()
    fields["departure_at"] = body.departure_at.isoformat()
    route = Route(driver_id=user_id, **fields)
    db.add(route)
    db.commit()
    return json_response(route_json(route), 201)


@router.get("/routes/{route_id}")
def get_route(route_id: ResourceId, user_id: int = Depends(require_auth), db: Session = Depends(get_db)):
    return json_response(route_json(find_route(db, route_id)))


@router.put("/routes/{route_id}")
def update_route(route_id: ResourceId, body: RouteBody, user_id: int = Depends(require_auth), db: Session = Depends(get_db)):
    db.execute(text("BEGIN IMMEDIATE"))
    route = find_route(db, route_id, user_id)
    require_no_bookings(db, route_id)
    for key, value in body.model_dump().items():
        setattr(route, key, value.isoformat() if key == "departure_at" else value)
    db.commit()
    return json_response(route_json(route))


@router.delete("/routes/{route_id}")
def delete_route(route_id: ResourceId, user_id: int = Depends(require_auth), db: Session = Depends(get_db)):
    db.execute(text("BEGIN IMMEDIATE"))
    route = find_route(db, route_id, user_id)
    require_no_bookings(db, route_id)
    route.deleted = True
    db.commit()
    return Response(status_code=204)
