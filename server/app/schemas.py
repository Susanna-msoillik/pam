from datetime import datetime, timezone
from zoneinfo import ZoneInfo
from typing import Annotated, Any, Literal

from pydantic import BaseModel, Field, StringConstraints, field_validator, model_validator

LOCAL_TZ = ZoneInfo("Europe/Chisinau")

NonEmptyString = Annotated[
    str, StringConstraints(strict=True, strip_whitespace=True, min_length=1)
]
TrimmedString = Annotated[str, StringConstraints(strict=True, strip_whitespace=True)]


class RegisterBody(BaseModel):
    email: NonEmptyString
    password: NonEmptyString
    name: NonEmptyString

    @field_validator("email")
    @classmethod
    def valid_email(cls, value: str) -> str:
        if "@" not in value:
            raise ValueError("A valid email is required")
        return value


class LoginBody(BaseModel):
    email: NonEmptyString
    password: NonEmptyString


class NoteBody(BaseModel):
    title: NonEmptyString
    content: str = ""

    @field_validator("content", mode="before")
    @classmethod
    def content_or_empty(cls, value: Any) -> str:
        return value if isinstance(value, str) else ""


class RouteBody(BaseModel):
    from_city: NonEmptyString = Field(alias="fromCity")
    to_city: NonEmptyString = Field(alias="toCity")
    departure_at: datetime = Field(alias="departureAt")
    seats_total: int = Field(alias="seatsTotal", strict=True, gt=0, lt=2**31)
    price: float = Field(gt=0, allow_inf_nan=False)

    @field_validator("departure_at")
    @classmethod
    def future_departure(cls, value):
        value = value.replace(tzinfo=LOCAL_TZ) if value.tzinfo is None else value
        if value <= datetime.now(timezone.utc):
            raise ValueError("Departure must be in the future")
        return value.astimezone(timezone.utc)

    @model_validator(mode="after")
    def different_cities(self):
        if self.from_city.casefold() == self.to_city.casefold():
            raise ValueError("Cities must differ")
        return self


class BookingBody(BaseModel):
    route_id: int = Field(alias="routeId", strict=True, gt=0, lt=2**63)
    seats: int = Field(strict=True, gt=0, lt=2**31)


class BookingUpdateBody(BaseModel):
    status: Literal["cancelled"]
