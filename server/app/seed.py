from datetime import datetime, timedelta, timezone

from sqlalchemy import select

from .auth import hash_password
from .models import Route, User


def seed_routes(db):
    if db.scalar(select(Route.id).limit(1)) is not None:
        return
    drivers = []
    for index, name in enumerate(["Андрей Русу", "Мария Чобану", "Виктор Мунтяну", "Елена Попеску", "Даниел Кожокару", "Алина Коваль"]):
        email = f"driver{index+1}@example.com"
        user = db.scalar(select(User).where(User.email == email))
        if user is None:
            user = User(email=email, name=name, password_hash=hash_password("driver123"))
            db.add(user)
            db.flush()
        drivers.append(user)
    cities = ["Бельцы", "Оргеев", "Кагул", "Унгены", "Сороки", "Хынчешты", "Комрат", "Страшены"]
    now = datetime.now(timezone.utc)
    for index in range(32):
        destination = cities[index % len(cities)]
        db.add(Route(driver_id=drivers[index % len(drivers)].id,
                     from_city="Кишинёв" if index % 3 else destination,
                     to_city=destination if index % 3 else "Кишинёв",
                     departure_at=(now + timedelta(days=1+index//3, hours=index%3)).isoformat(),
                     seats_total=3+index%2, price=40.0+10*(index%9)))
    db.commit()
