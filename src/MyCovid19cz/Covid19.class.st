"
Covid19 new grafCovid: 'cases'.
Covid19 new grafCovid: 'deaths'.

country,
country_code,
continent,
population,
indicator,
weekly_count,
year_week,
rate_14_day,
cumulative_count,
source

country,country_code,continent,population,indicator,weekly_count,year_week,rate_14_day,cumulative_count,source
Afghanistan,AFG,Asia,38928341,cases,0,2020-01,,0,""Epidemic intelligence, national weekly data""
Afghanistan,AFG,Asia,38928341,cases,0,2020-02,0,0,""Epidemic intelligence, national weekly data""
Afghanistan,AFG,Asia,38928341,cases,0,2020-03,0,0,""Epidemic intelligence, national weekly data""

Stahovatelný datový soubor obsahuje informace o 14denní míře hlášení nově hlášených případů COVID-19 na 100 000 obyvatel a 14denní míře hlášení hlášených úmrtí na milion obyvatel podle týdne a země. Každý řádek obsahuje odpovídající údaje pro určitý den a pro každou zemi. Soubor se aktualizuje každý týden. Data můžete používat v souladu se zásadami autorských práv ECDC.



Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	data:		<Object>


    Implementation Points
"
Class {
	#name : #Covid19,
	#superclass : #Object,
	#instVars : [
		'data',
		'xValues',
		'yValues'
	],
	#category : #MyCovid19cz
}

{ #category : #'as yet unclassified' }
Covid19 >> grafCovid [

|chart color b  covCases|

color := NSScale category20.
"Build the visualization"

covCases := self loadCzechiaData: 'cases'.
yValues := self prepareY: covCases.
xValues := self prepareX: covCases.


chart := RSChart new.
chart extent: 600 @ 600.
chart colors: color.
yValues  do: [ :datac | chart addPlot:(RSLinePlot new x: xValues  y: datac) ].
chart xlabel: 'Weeks ago'.
chart ylabel: 'Contaminated '.
chart title: 'Coronavirus cases weekly'.
chart addDecoration: (RSHorizontalTick new  fontSize: 10).
chart addDecoration: (RSVerticalTick new integerWithCommas; fontSize: 10).
chart ySqrt.
chart build.

b := RSLegend new.
b container: chart canvas.
"countries with: chart plots do: [ :c : p |
	b text: c withBoxColor: (chart colorFor: p) ].
b layout horizontal gapSize: 30."
b build.
b canvas open

]

{ #category : #'as yet unclassified' }
Covid19 >> grafCovid: aCases [

|chart color b  covCases|

color := NSScale category20.
"Build the visualization"
covCases := self loadCzechiaData: aCases.
yValues := self prepareY: covCases.
xValues := self prepareX: covCases.


chart := RSChart new.
chart extent: 600 @ 600.
chart colors: color.
yValues  do: [ :datac | chart addPlot:(RSLinePlot new x: xValues  y: datac) ].
chart xlabel: 'Weeks ago' offset: 20.
chart ylabel: 'Contaminated ' offset: -60.
chart title: 'Coronavirus cases weekly'.
chart addDecoration: (RSHorizontalTick new  fontSize: 10).
chart addDecoration: (RSVerticalTick new integerWithCommas; fontSize: 10).
chart ySqrt.
chart build.

b := RSLegend new.
b container: chart canvas.
"countries with: chart plots do: [ :c : p |
	b text: c withBoxColor: (chart colorFor: p) ].
b layout horizontal gapSize: 30."
b build.
b canvas open

]

{ #category : #'as yet unclassified' }
Covid19 >> loadCzechiaData: aIndikator [
  |c d dataFrame colDataFrame dataCz|
c := (ZnEasy get: 'https://opendata.ecdc.europa.eu/covid19/nationalcasedeath/csv') contents.
c := ZnCharacterEncoder  utf8  decodeBytes: c.
d := c copyReplaceAll: String crlf  with: String lf,' '.
dataFrame := DataFrame readFromCsv: d withSeparator: $,.
colDataFrame := dataFrame columns: #('country' 'indicator' 'weekly_count' 'year_week').
dataCz := colDataFrame select:
	   [ :row | row first = ' Czechia'  ].
data := dataCz select: 
     	[ :row | row second  = aIndikator ] .
^ data.   
]

{ #category : #'as yet unclassified' }
Covid19 >> prepareX: aDataFrame [ 

|indexX|

indexX := ( 1 to: aDataFrame size ) reversed negated.
xValues := indexX.
^ xValues.
]

{ #category : #'as yet unclassified' }
Covid19 >> prepareY: aDataFrame [

|pom dataSum allDataSum|
dataSum    := OrderedCollection new.
allDataSum := OrderedCollection new.
	1 to: aDataFrame  size   do: [ :index |
	   pom := (aDataFrame  at: index at: 3 ) asInteger.
		dataSum add: pom].
allDataSum add: dataSum. "od nestarsi polozky ukladam tydenni prirustky"
 yValues := allDataSum.
^ yValues.
]