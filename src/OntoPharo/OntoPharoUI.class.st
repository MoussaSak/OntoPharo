"
OntoPharo main interface execute 

	'OntoPharo open' to run it. 
"
Class {
	#name : #OntoPharoUI,
	#superclass : #SpPresenter,
	#instVars : [
		'conceptListPresenter',
		'classListPresenter',
		'methodListPresenter',
		'instanceVariablePresenter',
		'suggestionPresenter',
		'tfs',
		'button',
		'aPackage',
		'packageListPresenter',
		'questionLabel',
		'instanceVariableTFS',
		'methodTFS',
		'instanceVariableConceptPresenter',
		'instanceVariableNameSuggestion',
		'aClass',
		'bgramClassSuggestionPresenter'
	],
	#classInstVars : [
		'refresher',
		'instance'
	],
	#category : #'OntoPharo-UI'
}

{ #category : #specs }
OntoPharoUI class >> defaultSpec [
	
	
	^ SpBoxLayout newVertical
	
		add:
			(SpBoxLayout newHorizontal 
				add: #packageListPresenter ;
				add: #classListPresenter;
				"add: #methodListPresenter ;
				add: #instanceVariablePresenter;"
				add: #conceptListPresenter;
				add: #suggestionPresenter;
				add: #bgramClassSuggestionPresenter;			
				yourself);
		add:
			(SpBoxLayout newHorizontal 
				add: #questionLabel ;
				add: #button;
				yourself) withConstraints: [ :constraints | constraints height: 30 ];
		yourself
		 
]

{ #category : #specs }
OntoPharoUI class >> killRefresh [

	refresher unregister
]

{ #category : #specs }
OntoPharoUI class >> new [
	instance := super new. 
	refresher := OntoEventBroker new.
	refresher addUI: instance.
	^ instance
]

{ #category : #specs }
OntoPharoUI class >> open [

	"self open"
	<script>
	
	| presenter windowPresenter |
	presenter := self new. 
	presenter packages: RPackageOrganizer default packages.
	windowPresenter := presenter openWithSpec.
	windowPresenter whenClosedDo: [ 
		self killRefresh. 
		self refresher uiList remove: instance].
	"windowPresenter whenClosedDo: presenter getWhenClosedBlock."
	windowPresenter window extent: 1000@600.
	^ windowPresenter
]

{ #category : #accessing }
OntoPharoUI class >> refresher [
	^ refresher
]

{ #category : #specs }
OntoPharoUI class >> title [ 
	^'OntoPharo'
]

{ #category : #api }
OntoPharoUI >> buttonHandler [
	"handels the button work"
	| newName selectedSuggestion selectedConcept selectedClass |
	selectedConcept := self getSelectedConcept.
	selectedSuggestion := self getSelectedSuggestion.
	selectedClass := classListPresenter
		displayValueAt: classListPresenter selection selectedIndex.
	newName := self
		replaceConcept: selectedConcept
		with: selectedSuggestion.
	^ self refactorClassName: selectedClass to: newName
]

{ #category : #accessing }
OntoPharoUI >> classes: aList [

	classListPresenter items = aList
		ifTrue: [ ^ self ].
	classListPresenter
		items: aList;
		selectIndex: 1 
]

{ #category : #initialization }
OntoPharoUI >> connectPresenters [
	super connectPresenters.
	packageListPresenter	
		transmitTo: classListPresenter
		transform: self extractClasses
		postTransmission: [ :destination | destination selectIndex: 1 ]. 	
	classListPresenter
		transmitTo: methodListPresenter
		transform: self extractMethods
		postTransmission: [ :destination | destination selectIndex: 1 ].
	classListPresenter
		transmitTo: instanceVariablePresenter
		transform: self extractInstanceVariables
		postTransmission: [ :destination | destination selectIndex: 1 ].
	classListPresenter
		transmitTo: conceptListPresenter
		transform: self extractConcepts
		postTransmission: [ :destination | destination selectIndex: 1 ].
	conceptListPresenter
		transmitTo: suggestionPresenter
		transform: self proposeSuggestions
		postTransmission: [ :destination | destination selectIndex: 1 ] .
	conceptListPresenter 
		transmitTo: bgramClassSuggestionPresenter 
		transform: self proposeBigramsSuggestions 
		postTransmission: [ :destination | destination selectIndex: 1 ].
		
	button
		action: [ self buttonHandler ]
]

{ #category : #api }
OntoPharoUI >> extractClasses [
	"Extract Classes from the selected Package"
	^ [ :aPackageName | 	
		aPackage := ((aPackageName asSymbol) asPackage).	
		self classes: ( aPackage classes asOrderedCollection).
		aPackage classes asOrderedCollection 
		]
]

{ #category : #api }
OntoPharoUI >> extractConcepts [
	"Extract Classes Names Concepts"
	^ [ :selectedClass | 
	
	aClass := selectedClass.
	tfs splitName: aClass name asString ]
]

{ #category : #api }
OntoPharoUI >> extractInstanceVariables [
	"Extract Instance Variables from a Class"
	^ [ :selectedClass | 
	instanceVariableTFS classInstanceVariables: selectedClass ]
]

{ #category : #api }
OntoPharoUI >> extractMethods [
	"Extract Methods from a given Class"
	^ [ :selectedClass | 
	methodTFS classAllMethodsNames: selectedClass]	

]

{ #category : #api }
OntoPharoUI >> getSelectedConcept [
	"Get the selected Concept fril the conceptListPrenter"
	^ conceptListPresenter
		displayValueAt: conceptListPresenter selection selectedIndex
]

{ #category : #api }
OntoPharoUI >> getSelectedSuggestion [
	"get the selected suggestion from the suggestionPreseneter"
	^ suggestionPresenter
		displayValueAt: suggestionPresenter selection selectedIndex
]

{ #category : #initialization }
OntoPharoUI >> initializePresenters [

	tfs := TermsFeatureSelector new.
	methodTFS := MethodTermsFeatureSelector new.
	instanceVariableTFS := InstanceVariableFeatureSelector new.
	packageListPresenter := self newList headerTitle: 'Packages'.
	classListPresenter := self newList headerTitle: 'Class Names'.
	methodListPresenter := self newList headerTitle: 'Methods Names'.
	instanceVariablePresenter := self newList headerTitle: 'Instance Variables Names'.
	conceptListPresenter := self newList headerTitle: 'Class Name Concepts'.
	suggestionPresenter := self newList headerTitle: 'Class Name Suggestions'.
	bgramClassSuggestionPresenter := self newList headerTitle: 'Class Name Bgram Suggestions'.
	questionLabel := self newLabel label: 'Do you want to apply the suggestion ?!'.
	button := self newButton label: 'Apply Suggestion'.
	
	self focusOrder
		add: packageListPresenter;
		add: classListPresenter;
		add: conceptListPresenter;
		add: suggestionPresenter;
		add: questionLabel;
		add: button
]

{ #category : #accessing }
OntoPharoUI >> packages: aList [
	
	packageListPresenter items = aList
	
		ifTrue: [ ^ self ].
	packageListPresenter
		items: ((aList collect: ([:aPackagee| aPackagee name asString])) sorted ) ;
		selectIndex: 1
]

{ #category : #api }
OntoPharoUI >> proposeBigramsSuggestions [
	"Propose Bigrams suggestions for Classes Names"
	^ [ :aConcept | 
		(tfs proposeBigrams: aConcept in: (aPackage name)) collect: [ :index|
		(index history last, index last)
		 ]
		]
		
		
	
]

{ #category : #api }
OntoPharoUI >> proposeSuggestions [
	"Propose class Name suggestion based on the other classes concepts names"
	^ [ :aConcept | 
		(tfs sortedConceptsByLevenshteinDistanceOf: aConcept in: (aPackage name))
			collect: #key ]
		
		
	
]

{ #category : #accessing }
OntoPharoUI >> refactorClassName: aClassNamed to: newName [  

"Refactoring class Name to a new Name"

(RBRefactoryChangeFactory instance renameClass: aClassNamed asClass to: newName) execute

]

{ #category : #api }
OntoPharoUI >> replaceConcept: selectedConcept with: selectedSuggestion [ 

	"This method replaces the selected concept in the tables with the selected suggestion"
			|selectedClass |
			selectedClass := classListPresenter  displayValueAt: (classListPresenter selection selectedIndex).
			^ selectedClass  copyReplaceAll: selectedConcept with: selectedSuggestion.   
]

{ #category : #initialization }
OntoPharoUI >> selectClass: selectedClass [
	"Selects a Class in the UI."
	
	| classIndex|
	self selectPackage: selectedClass.
	classIndex := (classListPresenter items indexOf: selectedClass ifAbsent: [ self error: ('Class {1} not found' format: { selectedClass name }) ]).
	classListPresenter clickAtIndex: classIndex.
]

{ #category : #initialization }
OntoPharoUI >> selectMethod: aMethod [

	"Selects a Method in the UI."

	| aMethodName methodIndex|
	self selectClass: (aMethod methodClass).
	aMethodName := aMethod name withoutPrefix: (aMethod methodClass name asString ),'>>#'.
	methodIndex := (methodListPresenter items indexOf: aMethodName ifAbsent: [ self error: ('Method {1} not found' format: { aMethodName }) ]).
	methodListPresenter selectIndex: methodIndex
]

{ #category : #initialization }
OntoPharoUI >> selectPackage: selectedClass [

	"Selects aClass in the UI."
	| packageIndex|
	
	packageIndex := (packageListPresenter items indexOf: (selectedClass package name asString)  ifAbsent: [ self error: ('Package {1} not found' format: { selectedClass package name }) ]).
	packageListPresenter clickAtIndex: packageIndex.
]
