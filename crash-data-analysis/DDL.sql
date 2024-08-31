-- Drop existing tables and types with conflicting names - DO NOT RUN IF TABLES CONTAIN DATA YOU WANT TO KEEP
DROP TABLE IF EXISTS IncidentData CASCADE;
DROP TYPE IF EXISTS road_conditions CASCADE;
DROP TYPE IF EXISTS body_types CASCADE;
DROP TYPE IF EXISTS collision_types CASCADE;
DROP TYPE IF EXISTS weather_conditions CASCADE;


-- defining enums
CREATE TYPE weather_conditions as ENUM (
    'Clear',
    'Light Clouds',
    'Overcast',
    'Fog',
    'Light rain',
    'Heavy rain',
    'Light snow',
    'Heavy snow'
);

CREATE TYPE road_conditions AS ENUM (
    'Dry',
    'Wet',
    'Flooded',
    'Icy'
);

CREATE TYPE body_types AS ENUM (
    'Motorcycle',
	'Hatchback',
	'Sedan',
	'Wagon',
	'SUV or Light Truck',
	'Commercial Truck'
);

CREATE TYPE collision_types AS ENUM (
	'rear-end',
	'head-on',
	'side impact',
    'rollover'
);

-- Defining tables
CREATE TABLE IncidentData (
	IncidentID SERIAL PRIMARY KEY,
    IncidentLon VARCHAR(20),
	IncidentLat VARCHAR(20),
	IncidentElevation_m INTEGER,
    IncidentTime TIME NOT NULL,
    IncidentDate DATE NOT NULL,
    CollisionType collision_types,
    Injuries BOOLEAN,
    Fatalities BOOLEAN,
    SurfaceCoefficient_Percent FLOAT,
    Gradient_Percent INTEGER,
    WeatherCondition weather_conditions,
    RoadCondition road_conditions,
    EstResponseTime_min INTEGER,

    VehicleAMake VARCHAR(20),
    VehicleABodyType body_types,
    VehicleAEstSpeed_kmh INTEGER,
    VehicleANumOccupants INTEGER,
    VehicleADriverAge INTEGER,
    VehicleADriverYOE INTEGER,
    VehicleABrakeDist_m INTEGER,

    VehicleBMake VARCHAR(20),
    VehicleBBodyType VARCHAR(20),
    VehicleBEstSpeed_kmh INTEGER,
    VehicleBNumOccupants INTEGER,
    VehicleBDriverAge INTEGER,
    VehicleBDriverYOE INTEGER,
    VehicleBBrakeDist_m INTEGER
);

-- Uncomment to ensure that the statements above work as intended
-- SELECT * FROM IncidentData;