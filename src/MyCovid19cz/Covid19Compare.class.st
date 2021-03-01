"
'Czechia' 'Slovakia' 'Austria' 'Poland' 'Germany'

Playground
----------
a := Covid19Compare new. 
a loadData.
a grafCovidComp.

.... Do-it


Covid19Compare new drawn.   ""Simulation""
"
Class {
	#name : #Covid19Compare,
	#superclass : #Object,
	#instVars : [
		'allDataSum',
		'nbColumns',
		'countries'
	],
	#category : #MyCovid19cz
}

{ #category : #'as yet unclassified' }
Covid19Compare >> drawn [
	| canvas extent mainScale curveScale yscale color axis title ytitle xtitle lineTitle line curve normalY spoint |
	canvas := RSCanvas new.
	extent := 500@250.
	mainScale := NSScale linear
		domain: {0@0. 100@100};
		range: {0@extent y. extent x@ 0}.
	curveScale := NSScale linear
		domain: #(0 0.5 1);
		range: #(50 90 50).
	yscale := NSScale linear
		domain: #(40 100);
		range: #(500 40).
	color := NSScale linear
		domain: #(40 80 100);
		range: { Color red. Color orange. Color green }.
	axis := RSPolyline new
		controlPoints:  ({ 0@100. 0@0. 100@0} collect: [:p| mainScale scale: p]);
		markerStartEnd: (RSShapeFactory arrow
			extent: 10@15;
			color: Color black);
		yourself.
	title := RSLabel new
		text: 'Simulation';
		bold;
		fontSize: 20;
		position: (mainScale scale: 50@100);
		yourself.
	ytitle := RSLabel new
		text: 'Number of cases';
		bold;
		position: (mainScale scale: -3@ 50);
		rotateByDegrees: -90;
		yourself.
	xtitle := RSLabel new
		text: 'Time';
		bold;
		position: (mainScale scale: 50@ -7);
		yourself.
	lineTitle := RSLabel new
		text: 'Heal care system capacity';
		bold;
		position: (mainScale scale: 75@ 30);
		yourself.
	line := RSLine new
		startPoint: (mainScale scale: 0@20);
		dashArray: #(10);
		endPoint: (mainScale scale: 100@20);
		yourself.
	curve := RSSVGPath new withBorder.
	normalY := [ :x :mean :std |
		(-0.5 * (2* Float pi) log - std log -
		 ( ((x - mean) raisedTo: 2) / (2 * std * std))) exp].
	spoint := [ :s :p | s << p x asFloat asString; space; << p y asFloat asString ].
	canvas newAnimation
		repeat;
		duration: 10 seconds;
		scale: curveScale;
		onStepDo: [ :t | 
			| low upp mean stdDev series y first |
			low := 0.
			upp := t.
			mean := (low + upp) / 2.
			stdDev := (upp - low) / 4.
			first := nil.
			series := (low to: upp) collect: [ :x | 
				y := normalY value: x value: mean value: stdDev.
				y := y * (yscale scale: t).
				first ifNil: [ first := y ].
				mainScale scale: x @ (y - first ) ].
			curve svgPath: (String streamContents: [ :s |
				s << 'M'.
				spoint value: s value: (mainScale scale: 0@0).
				series do: [ :p | s << 'L'. spoint value: s value: p ].
				s << 'L'.
				spoint value: s value: series last x@ 250.
				s << 'Z' ]).
			
			curve paint: (color scale: t).
			canvas signalUpdate.
			].
	canvas add: axis.
	canvas add: title.
	canvas add: ytitle.
	canvas add: xtitle.
	canvas add: curve. 
	canvas add: line.
	canvas add: lineTitle.
	canvas @RSCanvasController.
	canvas open.


]

{ #category : #'as yet unclassified' }
Covid19Compare >> grafCovidComp [

|indexX color chart b|

indexX := (1 to: nbColumns - 4) reversed negated.

color := NSScale category20.
"Build the visualization"
chart := RSChart new.
chart extent: 400 @ 400.
chart colors: color.
allDataSum do: [ :data | chart addPlot:(RSLinePlot new x: indexX y: data) ].
chart xlabel: 'Days ago' offset: 20.
chart ylabel: 'Contaminated ' offset: -70.
chart title: 'Coronavirus confirmed cases'.
chart addDecoration: (RSHorizontalTick new  fontSize: 10).
chart addDecoration: (RSVerticalTick new integerWithCommas; fontSize: 10).
chart ySqrt.
chart build.

b := RSLegend new.
b container: chart canvas.
countries with: chart plots do: [ :c : p |
	b text: c withBoxColor: (chart colorFor: p) ].
b layout horizontal gapSize: 30.
b build.
b canvas open

]

{ #category : #'as yet unclassified' }
Covid19Compare >> loadData [

|url content dataFrame  dataSum subDataFrame|

countries := #('Czechia' 'Slovakia' 'Austria' 'Poland' 'Germany').
url := 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv'.

content := (ZnEasy get: url) contents.
dataFrame := DataFrame readFromCsv: content withSeparator: $,.

nbColumns := ((dataFrame columnAt: dataFrame numberOfColumns) asSet includes: nil)
	ifTrue: [ dataFrame numberOfColumns - 1 ]
	ifFalse: [ dataFrame numberOfColumns ].

allDataSum := OrderedCollection new.



countries do: [ :country |
   dataSum := OrderedCollection new.
	subDataFrame := dataFrame select: [ :row | row second = country ].
	(5 to: nbColumns) do: [ :index |
		dataSum add: (subDataFrame columnAt: index) sum ].
	allDataSum add: dataSum.
].

^ allDataSum.

]
