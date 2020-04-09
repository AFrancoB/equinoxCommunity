(
var path = thisProcess.nowExecutingPath.dirname;
var file = path++"/equinoxData.csv";

~map= CSVFileReader.read(file);
);

// post the data for the map
~map.size.do{|i|   ~map[i][2..5].postln  };


// functions to retrieve the data
(
~timePerTerritory = { | countryString |
	var countryData, time;
	countryData= ~map.select({|j,i|
		j[3].containsi(countryString.asString)});

	time = countryData.collect({|j,i|
		j[4].split($ )[0].asInteger}).sum {|j| j*60};

	time.asTimeString
};
~langsUsed = { | lang |
	var langData, performances;
	langData= ~map.select({|j,i|
		j[5].containsi(lang.asString)});

	performances= langData.collect({|j,i| j[2]});

	(perfs:performances, many: performances.size)
};
~getCoords = {| country |
	var place = ~map.select({|j,i| j[3].contains(country.asString)});

	(x: place[0][0].asFloat,y: place[0][1].asFloat)

};
~regions = {| aRegions  |

	var time= aRegions.collect { |j|  ~timePerTerritory.(j)   };

	time= time.collect {|j| j};
	time.collect({|j| j.asSecs*60}).sum.asTimeString



}
);


( // nationalities grouped together in regions
~europe= ["UK", "Scotland", "Russia", "Spain", "Italy", "Ukraine", "Switzerland", "Georgia", "Hungary", "England", "France", "Germany", "Denmark", "Belgium","Czech Republic", "The Netherlands"];

~uk= ["UK","Scotland","England"];
~europeNorth= ["Switzerland", "Germany", "Denmark","Belgium","The Netherlands"];
~europeSur= ["Spain", "Italy","France"];
~europeEast= ["Russia","Ukraine","Georgia","Hungary","Czech Republic"];
~europeWest= ["UK", "Scotland","Switzerland", "Germany", "Denmark","Belgium","The Netherlands"] ++ ~europeSur;
~centralAmerica= ["Costa Rica"];
~sudamerica= ["Argentina","Chile","Ecuador","Brazil","Colombia"];
~chinaAndSEAsia= ["China", "Indonesia"];
~middleEast= ["Palestina"];
~india= ["India"];
~oceania= ["Australia", "New Zealand"];
~antartica= ["Various global locations","world ensemble","Undisclosed realm","somewhere"];
~northamerica= ["USA","Canada","Mexico"];
~angloamerica= ["USA", "Canada"];
~latinamerica= ["Mexico"] ++ ~centralAmerica ++ ~sudamerica;
~southCone= ["Chile","Argentina"];
~eastAsia= ["China","Indonesia","Japan"];
);


(
// this are the regions used
~regions.(~sudamerica).asSecs;
~regions.(~europeEast).asSecs;
~regions.(~europeSur).asSecs;
~regions.(~europeNorth).asSecs;
~timePerTerritory.("USA").asSecs;
~timePerTerritory.("Japan").asSecs;
~timePerTerritory.("Canada").asSecs;
~regions.(~centralAmerica).asSecs;
~regions.(~chinaAndSEAsia).asSecs;
)

( // evaluate here for animated map
var w = Window("animated map", Rect(0, 0, 360*3.5, 180*3.5)).front;
var u = UserView(w, Rect(0, 0, 360*3.5, 190*3.5));
var lat = ~map.collect({|item|  item[0] });
var lon = ~map.collect({|item|  item[1] });
var time = ~map.collect({|item| item[4].split($ )[0].asInteger});
time = time.reject({|j| j==0})*0.03;
~index= 0;
Tdef(\seq, {
	1.wait;
	(~map.size-1).do{|i|
		~map[i+2].postln;
		~index = i+1;
		time[i+1].wait;
	}
}).play;
u.background = Color.black;
u.animate = true; //animate this view
CmdPeriod.doOnce({if(w.isClosed.not, {w.close; Tdef(\seq).stop})});

lat = lat.select({|item|  item!="Lat"  }).collect({|item| item.asFloat});
lon = lon.select({|item|  item!="Lon"  }).collect({|item| item.asFloat});

//Pen.moveTo(Point());
u.drawFunc = { |v|

	Pen.strokeColor = Color(0.2,0.2,0.2);
	(~map.size-2).do{|i|
		Pen.line(
			Point(lon[i].linlin(-180,180,0,360*3),lat[i].linlin(-90,90,180*3,0)),
			Point(lon[i+1].linlin(-180,180,0,360*3),lat[i+1].linlin(-90,90,180*3,0))
		);
	};
	Pen.stroke;

	Pen.strokeColor = Color.white;
	Pen.fillColor = Color.white;
		(~map.size-2).do{|i|
		Pen.stringAtPoint(~map[i+1][2],Point(lon[i].linlin(-180,180,0,360*3),lat[i].linlin(-90,90,180*3,0)),color: Color(0.1,0.1,0.3));

	};
	Pen.moveTo(if(~index==0, {
		Point(lon[~index].linlin(-180,180,0,360*3),lat[~index].linlin(-90,90,180*3,0))
	},
	{
		Point(lon[~index-1].linlin(-180,180,0,360*3),lat[~index-1].linlin(-90,90,180*3,0))
	}));
	Pen.lineTo(Point(lon[~index].linlin(-180,180,0,360*3),lat[~index].linlin(-90,90,180*3,0)));

	Pen.addOval(Rect(lon[~index].linlin(-180,180,0,360*3),lat[~index].linlin(-90,90,180*3,0), 3, 3));
	Pen.strokeColor = Color(0.9,0.9,0.9);
	// back 1
	Pen.line(
		if(~index < 2, {Point(0,0)}, {Point(lon[~index-2].linlin(-180,180,0,360*3),lat[~index-2].linlin(-90,90,180*3,0))}),
		if(~index < 2, {Point(0,0)}, {Point(lon[~index-1].linlin(-180,180,0,360*3),lat[~index-1].linlin(-90,90,180*3,0))})
	);

	Pen.stringAtPoint(~map[~index+1][2], Point(lon[~index].linlin(-180,180,0,360*3),lat[~index].linlin(-90,90,180*3,0)));
	Pen.stringAtPoint(~map.collect({|item| item[2..6] })[~index+1].asString,Point(10,10),color: Color.white);
	Pen.stringAtPoint(~map.collect({|item| item[2..6] })[~index+2].asString,Point(10,30),color: Color(0.5,0.5,0.5));


	Pen.stroke;
	Pen.fill;

};
)

(
// map usefull to interpret the data, evaluate it after evaluating a configuration
var w = Window("mapa", Rect(0, 0, 360*3.5, 180*3.5)).front;
//var u = UserView(w, Rect(0, 0, 360*3.5, 190*3.5));
var lat = ~map.collect({|item|  item[0] });
var lon = ~map.collect({|item|  item[1] });
var time = ~map.collect({|item| item[4].split($ )[0].asInteger});
time = time.reject({|j| j==0})*0.05;
~index= 0;

w.background = Color.black;
//w.animate = true; //animate this view
CmdPeriod.doOnce({if(w.isClosed.not, {w.close; })});

lat = lat.select({|item|  item!="Lat"  }).collect({|item| item.asFloat});
lon = lon.select({|item|  item!="Lon"  }).collect({|item| item.asFloat});

//Pen.moveTo(Point());
w.drawFunc = { |v|
	Pen.strokeColor = Color.white;
	Pen.fillColor = Color.white;
		(~map.size-1).do{|i|
		Pen.stringAtPoint(~map[i+1][2],Point(lon[i].linlin(-180,180,0,360*3),lat[i].linlin(-90,90,180*3,0)),color: Color(0.2,0.2,0.2));
	};
	~regionsBySize.size.do{|i|
		Pen.addOval(Rect(
			~regionsBySize[i].coordY.linlin(-180,180,0,360*3),
			~regionsBySize[i].coordX.linlin(-90,90,180*3,0),
			~regionsBySize[i].data.asSecs.linlin(0,3810,5,100),
			~regionsBySize[i].data.asSecs.linlin(0,3810,5,100)));
		Pen.stringAtPoint(~regionsBySize[i].tag,
			Point(
				~regionsBySize[i].coordY.linlin(-180,180,0,360*3+30),
				~regionsBySize[i].coordX.linlin(-90,90,180*3,0)
			)
		);
		Pen.stringAtPoint((~regionsBySize[i].data).asString + "time for" + ~regionsBySize[i].tag,Point(10,200+(20*i)));

	};


	Pen.stroke;
	Pen.fill;

};
);


( // config 1 (by big regions)
~regionsBySize= [
	(coordX: ~getCoords.("UK").x,coordY: ~getCoords.("UK").y, data: ~regions.(~europeWest), tag: "West/North/South Europe"),
	(coordX: ~getCoords.("Costa Rica").x,coordY: ~getCoords.("Costa Rica").y, data: ~regions.(~latinamerica), tag: "Latinamerica"),
	(coordX: ~getCoords.("USA").x,coordY: ~getCoords.("USA").y, data: ~regions.(~angloamerica), tag: "Angloamerica"),
	(coordX: ~getCoords.("Japan").x,coordY: ~getCoords.("Japan").y, data: ~regions.(~eastAsia), tag: "East Asia"),
	(coordX: ~getCoords.("Russia").x,coordY: ~getCoords.("Russia").y, data: ~regions.(~europeEast), tag: "East Europe"),
	(coordX: ~getCoords.("Australia").x,coordY: ~getCoords.("Australia").y, data: ~regions.(~oceania), tag: "Oceania"),
	(coordX: ~getCoords.("Undisclosed realm").x,coordY: ~getCoords.("Undisclosed realm").y, data: ~regions.(~antartica), tag: "Global / undisclosed / delocalised locations "),
	(coordX: ~getCoords.("India").x,coordY: ~getCoords.("India").y, data: ~timePerTerritory.("India"), tag: "India"),
	(coordX: ~getCoords.("Israel").x,coordY: ~getCoords.("Israel").y, data: ~timePerTerritory.("Israel"), tag: "Palestine"),
]
);

( // config 2 (by countries)
~regionsBySize= [
	(coordX: ~getCoords.("Russia").x,coordY: ~getCoords.("Russia").y, data: ~regions.(~europeEast), tag: "East Europe"),
	(coordX: ~getCoords.("Germany").x,coordY: ~getCoords.("Germany").y, data: ~regions.(~europeNorth), tag: "West Europe"),
	(coordX: ~getCoords.("UK").x,coordY: ~getCoords.("UK").y, data: ~regions.(~uk), tag: "UK"),
	(coordX: ~getCoords.("Italy").x,coordY: ~getCoords.("Italy").y, data: ~regions.(~europeSur), tag: "South Europe"),
	(coordX: ~getCoords.("Brazil").x,coordY: ~getCoords.("Brazil").y, data: ~timePerTerritory.("Brazil"), tag: "Brazil"),
	(coordX: ~getCoords.("Colombia").x,coordY: ~getCoords.("Colombia").y, data: ~timePerTerritory.("Colombia"), tag: "Colombia"),
	(coordX: ~getCoords.("USA").x,coordY: ~getCoords.("USA").y, data: ~timePerTerritory.("USA"), tag: "USA"),
	(coordX: ~getCoords.("Japan").x,coordY: ~getCoords.("Japan").y, data: ~timePerTerritory.("Japan"), tag: "Japan"),
	(coordX: ~getCoords.("Canada").x,coordY: ~getCoords.("Canada").y, data: ~timePerTerritory.("Canada"), tag: "Canada"),
	(coordX: ~getCoords.("Mexico").x,coordY: ~getCoords.("Mexico").y, data: ~timePerTerritory.("Mexico"), tag: "Mexico"),
	(coordX: ~getCoords.("Chile").x,coordY: ~getCoords.("Chile").y, data: ~timePerTerritory.("Chile"), tag: "Chile"),
	(coordX: ~getCoords.("Argentina").x,coordY: ~getCoords.("Argentina").y, data: ~timePerTerritory.("Argentina"), tag: "Argentina"),
	(coordX: ~getCoords.("Ecuador").x,coordY: ~getCoords.("Ecuador").y, data: ~timePerTerritory.("Ecuador"), tag: "Ecuador"),
	(coordX: ~getCoords.("Costa Rica").x,coordY: ~getCoords.("Costa Rica").y, data: ~regions.(~centralAmerica), tag: "Costa Rica"),
	(coordX: ~getCoords.("China").x,coordY: ~getCoords.("China").y, data: ~timePerTerritory.("China"), tag: "China"),
	(coordX: ~getCoords.("Indonesia").x,coordY: ~getCoords.("Indonesia").y, data: ~timePerTerritory.("Indonesia"), tag: "Indonesia"),
	(coordX: ~getCoords.("India").x,coordY: ~getCoords.("India").y, data: ~timePerTerritory.("India"), tag: "India"),
	(coordX: ~getCoords.("Australia").x,coordY: ~getCoords.("Australia").y, data: ~timePerTerritory.("Australia"), tag: "Australia"),
	(coordX: ~getCoords.("New Zealand").x,coordY: ~getCoords.("New Zealand").y, data: ~timePerTerritory.("New Zealand"), tag: "New Zealand"),
	(coordX: ~getCoords.("Israel").x,coordY: ~getCoords.("Israel").y, data: ~timePerTerritory.("Israel"), tag: "Palestine"),
	(coordX: ~getCoords.("Undisclosed realm").x,coordY: ~getCoords.("Undisclosed realm").y, data: ~regions.(~antartica), tag: "Global / undisclosed / delocalised locations ")
]
);

