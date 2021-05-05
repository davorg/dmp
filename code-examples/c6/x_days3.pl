use Date::Manip;

print UnixDate(DateCalc(ParseDateString('now'), "+${x}d"), 
               "%d/%m/%Y %H:%M:%S"); 
# Where $x is the number of days to add
