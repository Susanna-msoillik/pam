from sqlalchemy import Boolean, ForeignKey, Text, Index, false, text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .db import Base, now_iso


class User(Base):
    __tablename__ = "users"
    __table_args__ = {"sqlite_autoincrement": True}

    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(Text, unique=True)
    password_hash: Mapped[str] = mapped_column(Text)
    name: Mapped[str] = mapped_column(Text)
    created_at: Mapped[str] = mapped_column(Text, default=now_iso)


class Note(Base):
    __tablename__ = "notes"
    __table_args__ = {"sqlite_autoincrement": True}

    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    title: Mapped[str] = mapped_column(Text)
    content: Mapped[str] = mapped_column(Text, default="", server_default="")
    created_at: Mapped[str] = mapped_column(Text, default=now_iso)


class UploadedFile(Base):
    __tablename__ = "files"
    __table_args__ = {"sqlite_autoincrement": True}

    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    name: Mapped[str] = mapped_column(Text)
    mime_type: Mapped[str] = mapped_column(Text)
    size: Mapped[int]
    path: Mapped[str] = mapped_column(Text)
    created_at: Mapped[str] = mapped_column(Text, default=now_iso)


class Route(Base):
    __tablename__ = "routes"
    __table_args__ = {"sqlite_autoincrement": True}
    id: Mapped[int] = mapped_column(primary_key=True)
    driver_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    from_city: Mapped[str] = mapped_column(Text)
    to_city: Mapped[str] = mapped_column(Text)
    departure_at: Mapped[str] = mapped_column(Text, index=True)
    seats_total: Mapped[int]
    price: Mapped[float]
    deleted: Mapped[bool] = mapped_column(Boolean, default=False, server_default=false())
    driver: Mapped[User] = relationship(lazy="joined")


class Booking(Base):
    __tablename__ = "bookings"
    __table_args__ = (
        Index("one_active_booking", "passenger_id", "route_id", unique=True,
              sqlite_where=text("status = 'active'")),
        {"sqlite_autoincrement": True},
    )
    id: Mapped[int] = mapped_column(primary_key=True)
    route_id: Mapped[int] = mapped_column(ForeignKey("routes.id"), index=True)
    passenger_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    seats: Mapped[int]
    status: Mapped[str] = mapped_column(Text, default="active")
    created_at: Mapped[str] = mapped_column(Text, default=now_iso)
    route: Mapped[Route] = relationship(lazy="joined")
