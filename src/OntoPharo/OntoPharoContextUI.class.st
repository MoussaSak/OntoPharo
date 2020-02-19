"
OntoPharo for Class name suggestions based on Context  execute 

	'OntoPharoContextUI open' to run it. 
"
Class {
	#name : #OntoPharoContextUI,
	#superclass : #OntoPharoUI,
	#instVars : [
		'tfsc',
		'packagesByContextListPresenter',
		'classesByContextListPresenter',
		'methodsByContextListPresenter',
		'instanceVariablesByContextListPresenter',
		'classesByContextConceptListPresenter',
		'classesByContextSuggestionListPresenter',
		'classesByContextBigramSuggestionListPresenter'
	],
	#category : #'OntoPharo-Spec-UI'
}

{ #category : #specs }
OntoPharoContextUI class >> defaultSpec [
	
	
	^ SpBoxLayout newVertical
	
		add:
			(SpBoxLayout newHorizontal 
				add: #packagesByContextListPresenter;
				add: #classesByContextListPresenter;
				add: #classesByContextConceptListPresenter;
				add: #classesByContextSuggestionListPresenter;
				add: #classesByContextBigramSuggestionListPresenter;			
				yourself);
		add:
			(SpBoxLayout newHorizontal 
				add: #checkBoxMethod;
				add: #checkBoxClass;
				add: #checkBoxInstanceVar;
				add: #checkBoxContext;
				add: #checkBoxMain;
				yourself) withConstraints: [ :constraints | constraints height: 30];
		add:
			(SpBoxLayout newHorizontal 
				add: #questionLabel ;
				add: #button;
				yourself) withConstraints: [ :constraints | constraints height: 30 ];
		yourself
		 
]

{ #category : #specs }
OntoPharoContextUI class >> open [

	"self open"
	<script>
	
	| presenter windowPresenter |
	presenter := self new. 
	"presenter packages: RPackageOrganizer default packages."
	windowPresenter := presenter openWithSpec.
	windowPresenter whenClosedDo: [ 
		self killRefresh. 
		self refresher uiList remove: instance].
	"windowPresenter whenClosedDo: presenter getWhenClosedBlock."
	windowPresenter window extent: 1000@600.
	^ windowPresenter
]

{ #category : #specs }
OntoPharoContextUI class >> title [ 
	^'OntoPharoContextUI'
]

{ #category : #initialization }
OntoPharoContextUI >> connectPresenters [

	super connectPresenters.
	
	packageListPresenter  
		transmitTo: packagesByContextListPresenter 
		transform: self extractPackagesByContext 
		postTransmission: [ :destination | destination selectIndex: 1].
	packagesByContextListPresenter 
		transmitTo: classesByContextListPresenter 
		transform: self extractClasses 
		postTransmission: [ :destination | destination selectIndex: 1].
 	classesByContextListPresenter
		transmitTo: classesByContextConceptListPresenter
		transform: self extractConcepts
		postTransmission: [ :destination | destination selectIndex: 1 ].	
	classesByContextConceptListPresenter
		transmitTo: classesByContextSuggestionListPresenter 
		transform: self proposeSuggestions
		postTransmission: [ :destination | destination selectIndex: 1 ] .
	classesByContextConceptListPresenter 
		transmitTo: classesByContextBigramSuggestionListPresenter  
		transform: self proposeBigramsSuggestions 
		postTransmission: [ :destination | destination selectIndex: 1 ].
	button
		action: [ self buttonHandler]
]

{ #category : #api }
OntoPharoContextUI >> extractClasses [
	"Extract Classes from the selected Package"
	^ [ :packageName | 		
						
		packageName  
		ifNotNil: [ 
		tfsc context: (tfs splitName: packageName) first.
		tfsc packagesClassesByContext]
		ifNil: [ #() ] ]
]

{ #category : #api }
OntoPharoContextUI >> extractConcepts [
	"Extract Classes Names Concepts"
	^ [ :selectedClass | 
	selectedClass
	ifNotNil: [ 
		aClass := selectedClass.
		tfs splitName: aClass name asString ]
	ifNil:[ #() ] ]
]

{ #category : #api }
OntoPharoContextUI >> extractInstanceVariables [
	"Extract Instance Variables from a Class"
	^ [ :selectedClass | |aPackageName|
	selectedClass 
	ifNotNil: [ 
		aPackageName := selectedClass package packageName asString.
		tfsc context: (tfs splitName: aPackageName) first.
		tfsc packagesInstanceVariablesByContext.
	 ]
	ifNil: [ #() ] ]
]

{ #category : #api }
OntoPharoContextUI >> extractMethods [
	"Extract Methods from a given Class"
	^ [ :selectedClass | |aPackageName|
		selectedClass 
		ifNotNil:[
		aPackageName := selectedClass package packageName asString.
		tfsc context: (tfs splitName: aPackageName) first.
		tfsc packagesMethodsByContext collect:[:each|
			 each name withoutPrefix: (each methodClass name asString), '>>#'
			].]	
		ifNil: [ #() ] ]
]

{ #category : #api }
OntoPharoContextUI >> extractPackagesByContext [
	"Extract Classes from the selected Package"
	^ [ :aPackageName | 	
		aPackageName 
		ifNotNil: [ 	
		tfsc context: (tfs splitName: aPackageName) first.
		tfsc packagesByContext collect:[:each| each name asString].
		]
		ifNil: [ #() ] ]
]

{ #category : #api }
OntoPharoContextUI >> getSelectedConcept [
	^ classesByContextConceptListPresenter 
		displayValueAt: classesByContextConceptListPresenter selection selectedIndex
]

{ #category : #api }
OntoPharoContextUI >> getSelectedSuggestion [

	^ classesByContextSuggestionListPresenter 
		displayValueAt: classesByContextSuggestionListPresenter  selection selectedIndex
]

{ #category : #initialization }
OntoPharoContextUI >> initializePresenter [

	tfsc := TermsFeatureSelectorByContext new.
	
	packagesByContextListPresenter := self newList headerTitle: 'Packages by Context'.
	classesByContextListPresenter  := self newList headerTitle: 'Classes by Context'.
	classesByContextConceptListPresenter := self newList headerTitle: 'Classes Names Concepts'.
	classesByContextSuggestionListPresenter := self newList headerTitle: 'Classes Names Concepts'.
	classesByContextBigramSuggestionListPresenter := self newList headerTitle: 'Classes Names Concepts'.
	
	methodsByContextListPresenter  := self newList headerTitle: 'Methods by Context'.
	instanceVariablesByContextListPresenter := self newList headerTitle: 'Instance Variables by Context'.


]

{ #category : #api }
OntoPharoContextUI >> proposeSuggestions [
	"Propose class Name suggestion based on the other classes concepts names"
	^ [ :aConcept |
		 
		aPackage 
		ifNotNil:[
		(tfsc sortedConceptsByLevenshteinDistanceOf: aConcept)
		collect: #key ]
		ifNil: [ #() ] ]
		
]

{ #category : #api }
OntoPharoContextUI >> selectClass: selectedClass [
	"Selects a Class in the UI."
	aPackage := selectedClass package.
	aClass := selectedClass.
	self packages: RPackageOrganizer default packages.
	self selectPackage: selectedClass package.
	classesByContextListPresenter selectItem: selectedClass.
	
]
