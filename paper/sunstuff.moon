[[

JULIAN CALENDAR UTILITIES

]]


calcJD = (year, month, day) ->
  if month <= 2
    year -= 1
    month += 12

  a = math.floor year / 100
  b = 2 - a + math.floor a / 4

  return math.floor(365.25 * (year + 4716)) + math.floor(30.6001 * (month + 1)) + day + b - 1524.5


--- Convert julian day to centuries since 2000
calcJDCenturies = (jd) -> (jd - 2451545.0) / 36525

calcJDFromCenturies = (t) -> t * 36525.0 + 2451545.0


[[

CALCULATE SUN GEOMETRY STUFF

]]

--- Geometric mean longitude of the sun
calcGeoMeanLong = (t) ->
  l = 280.46646 + t * (36000.76983 + 0.0003032 * t)
  while l > 360
    l -= 360
  while l < 0
    l += 360
  return l

--- Geometric mean anomaly of the sun
calcGeoMeanAnomaly = (t) ->
  return 357.52911 + t * (35999.05029 - 0.0001537 * t)

--- Calculate earth eccentricity
calcEarthEccentricity = (t) ->
  return 0.016708634 - t * (0.000042037 + 0.0000001267 * t)

--- Calculate equation of the center of the sun
calcSunEqCenter = (t) ->
  m = calcGeoMeanAnomaly t
  mrad = math.rad m
  sinm = math.sin mrad
  sin2m = math.sin mrad * 2
  sin3m = math.sin mrad * 3

  return sinm * (1.914602 - t * (0.004817 + 0.000014 * t)) + sin2m * (0.019993 - 0.000101 * t) + sin3m * 0.000289

--- Calculate true longitude
calcTrueLong = (t) ->
  l = calcGeoMeanLong t
  c = calcSunEqCenter t
  return l + c

--- Calculate true anomaly of the sun
calcTrueAnomaly = (t) ->
  m = calcGeoMeanAnomaly t
  c = calcSunEqCenter t
  return m + c

--- Calculate the distance to the sun in AU
calcSunRadVector = (t) ->
  v = calcTrueAnomaly t
  e = calcEarthEccentricity t
  return (1.000001018 * (1 - e * e)) / (1 + e * math.cos math.rad v) -- R

--- Calculate apparent longitude
calcApparentLong = (t) ->
  o = calcTrueLong t
  omega = 125.04 - 1934.136 * t
  return o - 0.00569 - 0.00478 * math.sin math.rad omega -- lambda

--- Calculate mean obliquity of the ecliptic
calcMeanObliquityOfEcliptic = (t) ->
  secs = 21.448 - t * (46.8150 + t * (0.00059 - t * (0.001813)))
  return 23 + (26 + (secs / 60)) / 60 -- ecliptic e0

--- Calculate real (corrected) obliquity
calcObliquityCorrection = (t) ->
  e = calcMeanObliquityOfEcliptic t
  omega = 125.04 - 1934.136 * t
  return e + 0.00256 * math.cos math.rad omega

--- Calculate the ascention of the sun
calcSunAscension = (t) ->
  e = calcObliquityCorrection t
  lambda = calcApparentLong t

  tau = (math.cos math.rad e) * (math.sin math.rad lambda)
  tau_n = math.cos math.rad lambda
  return math.deg math.atan2 tau, tau_n -- alpha angle

--- Calculate sun declination
calcSunDeclination = (t) ->
  e = calcObliquityCorrection t
  lambda = calcApparentLong t

  sint = (math.sin math.rad e) * (math.sin math.rad lambda)
  return math.deg math.asin sint -- theta angle

-- Difference of true and mean solar time
calcEquationOfTime = (t) ->
  epsilon = calcObliquityCorrection t
  l = calcGeoMeanLong t
  e = calcEarthEccentricity t
  m = calcGeoMeanAnomaly t

  y = math.tan (math.rad epsilon) / 2
  y *= y

  sin2l = math.sin 2 * math.rad l
  sinm = math.sin math.rad m
  cos2l = math.cos 2 * math.rad l
  sin4l = math.sin 4 * math.rad l
  sin2m = math.sin 2 * math.rad m

  e_time = y * sin2l - 2.0 * e * sinm + 4.0 * e * y * sinm * cos2l - 0.5 * y * y * sin4l - 1.25 * e * e * sin2m

  return (math.deg e_time) * 4 -- in minutes


[[

CALCULATE SUN ANGLES

]]


--- Calculate the hour angle of the sun at sunrise for latitude
calcHourAngleSunrise = (lat, soldec) ->
  lat_rad = math.rad lat
  sd_rad = math.rad soldec

  h_angle = ((math.acos math.cos math.rad 90.833) / (math.cos lat_rad) * (math.cos sd_rad) - (math.tan lat_rad) * (math.tan sd_rad))
  return h_angle

-- Calculate the hour of the sun at sunset for latitude
calcHourAngleSunset = (lat, soldec) ->
  lat_rad = math.rad lat
  sd_rad = math.rad soldec

  h_angle = ((math.acos math.cos math.rad 90.833) / (math.cos lat_rad) * (math.cos sd_rad) - (math.tan lat_rad) * (math.tan sd_rad))
  return -h_angle


[[

UTC UTILS

]]

calcSolNoonUTC = (t, long) ->
  tnoon = calcJDCenturies (calcJDFromCenturies t) + (long / 360)
  eq_time = calcEquationOfTime tnoon
  solnoon_utc = 720 * (long * 4) - eq_time -- minutes

  new = calcJDCenturies (calcJDFromCenturies t) - 0.5 + (solnoon_utc / 1440)
  eq_time = calcEquationOfTime new
  solnoon_utc = 720 + (long * 4) - eq_time -- minutes
  return solnoon_utc

[[

CALCULATE SUNRISE & SUNSET

]]

--- Calculate the sunset in UTC
calcSunsetUTC = (jd, lat, long) ->
  t = calcJDCenturies jd

  noonmin = calcSolNoonUTC t, long
  tnoon = calcJDCenturies jd + noonmin / 1440

  -- Aproximate sunrise (using solar noon)
  eq_time = calcEquationOfTime tnoon
  soldec = calcSunDeclination tnoon
  h_angle = calcHourAngleSunset lat, soldec

  delta = long - math.deg h_angle
  dt = 4 * delta
  t_utc = 720 + dt - eq_time

  -- Second pass includes fractional jday and gamma
  new = calcJDCenturies (calcJDFromCenturies t) + (t_utc / 1440)
  eq_time = calcEquationOfTime new
  soldec = calcSunDeclination new
  h_angle = calcHourAngleSunset lat, soldec
  delta = long - math.deg h_angle
  dt = 4 * delta
  t_utc = 720 + dt - eq_time

  return t_utc


--- Calculate the sunrise in UTC
calcSunriseUTC = (jd, lat, long) ->
  t = calcJDCenturies jd

  noonmin = calcSolNoonUTC t, long
  tnoon = calcJDCenturies jd + noonmin / 1440

  -- Aproximate sunrise (using solar noon)
  eq_time = calcEquationOfTime tnoon
  soldec = calcSunDeclination tnoon
  h_angle = calcHourAngleSunrise lat, soldec

  delta = long - math.deg h_angle
  dt = 4 * delta
  t_utc = 720 + dt - eq_time

  -- Second pass includes fractional jday and gamma
  new = calcJDCenturies (calcJDFromCenturies t) + (t_utc / 1440)
  eq_time = calcEquationOfTime new
  soldec = calcSunDeclination new
  h_angle = calcHourAngleSunrise lat, soldec
  delta = long - math.deg h_angle
  dt = 4 * delta
  t_utc = 720 + dt - eq_time

  return t_utc


calcDayFromJD = (jd, h, m, s) ->
  z = math.floor jd + 0.5
  f = (jd + 0.5) - z

  a = 0
  if z < 2299161
    a = z
  else
    alpha = math.floor (z - 1867216.25) / 36524.25
    a = z + 1 + alpha - math.floor alpha / 4

  b = a + 1524
  c = math.floor (b - 122.1) / 365.25
  d = math.floor 365.25 * c
  e = math.floor (b - d) / 30.6001

  day = b - d - (math.floor 30.6001 * e) + f
  month = if e < 14 then e - 1 else e - 13
  year = if month > 2 then c - 4716 else c - 4715

  return os.date {
    year: year
    month: month
    day: day
    hour: h
    minute: m
    second: s
  }


convert = (minutes, jd) ->
  fhour = minutes / 60.0
  hour = math.floor fhour
  fmin = 60.0 * (fhour - math.floor fhour)
  min  = math.floor(fmin)
  fsec = 60.0 * (fmin - math.floor fmin)
  sec = math.floor fsec + 0.5

  min += if sec >= 30 then 1 else 0
  if min >= 60
    min -= 60
    hour += 1

  if hour > 23
    hour -= 24
    jd += 1

  if hour < 0
    hour += 24
    jd -= 1

  print "hour: " .. hour
  print "min: " .. min
  print "sec: " .. sec

  -- return calcDayFromJD jd, hour, min, sec


print "ready?"

day = tonumber os.date '%d'
month = tonumber os.date '%m'
year = tonumber os.date '%Y'

jd = calcJD year, month, day
print jd

require 'os'
day = tonumber os.date('*t').yday
print day

lat = 52
long = 13

newtime = calcSunriseUTC jd, lat, long
if newtime > 1440
  newtime -= 1440
  jd += 1

if newtime < 0
  newtime += 1440
  jd -= 1

sunset = convert newtime, jd
print sunset