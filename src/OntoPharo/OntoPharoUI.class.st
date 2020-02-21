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
		'bgramClassSuggestionPresenter',
		'checkBoxMethod',
		'checkBoxClass',
		'checkBoxInstanceVar',
		'checkBoxContext',
		'checkBoxMain'
	],
	#classInstVars : [
		'refresher',
		'instance'
	],
	#category : #'OntoPharo-Spec-UI'
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
	| newName selectedClass |
	
	selectedClass := classListPresenter
		displayValueAt: classListPresenter selection selectedIndex.
	newName := self
		replaceConcept: self getSelectedConceptIndex
		with: self getSelectedSuggestion.
	^ self refactorClassName: selectedClass to: newName
]

{ #category : #api }
OntoPharoUI >> checkBoxHandle: aCheckBox [ 
	
		|checkBoxeses|
	checkBoxeses := OrderedCollection new.
	checkBoxeses  add:  checkBoxClass; add: checkBoxMethod; add: checkBoxContext; add: 	checkBoxInstanceVar; add: checkBoxMain.
	
	aCheckBox whenActivatedDo: [ checkBoxeses reject: [:each| each = aCheckBox ] 
	thenDo:[ :each| each enabled: false].
	(aCheckBox = checkBoxMethod)
	ifTrue: [ OntoPharoMethodUI open].
	(aCheckBox = checkBoxClass)
	ifTrue: [ OntoPharoClassUI open ].
	(aCheckBox = checkBoxContext )
	ifTrue: [ OntoPharoContextUI open].
	(aCheckBox = checkBoxInstanceVar) 
	ifTrue: [OntoPharoInstanceVariableUI open].
	(aCheckBox = checkBoxMain) 
	ifTrue: [OntoPharoUI open. self delete]].

 	
	aCheckBox whenDeactivatedDo: [checkBoxeses reject: [:each| each = aCheckBox ] 
	thenDo:[ :each| each enabled: true]].

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
		transmitTo: conceptListPresenter
		transform: self extractConcepts
		postTransmission: [ :destination | destination selectIndex: 1 ].
	conceptListPresenter
		transmitTo: suggestionPresenter
		transform: self proposeSuggestions
		postTransmission: [ :destination | 
			destination selectIndex: 1.
			destination
				whenSelectionChangedDo: [ bgramClassSuggestionPresenter unselectAll ] ].
	conceptListPresenter
		transmitTo: bgramClassSuggestionPresenter
		transform: self proposeBigramsSuggestions
		postTransmission: [ :destination | 
			destination.
			destination
				whenSelectionChangedDo: [ suggestionPresenter unselectAll ] ].
	self checkBoxHandle: checkBoxMethod.
	self checkBoxHandle: checkBoxClass.
	self checkBoxHandle: checkBoxContext.
	self checkBoxHandle: checkBoxInstanceVar.
	button action: [ self buttonHandler ]
]

{ #category : #api }
OntoPharoUI >> extractClasses [
	"Extract Classes from the selected Package"
	^ [ :aPackageName | 
		aPackageName 
		ifNotNil: [ 
		aPackage := ((aPackageName asSymbol) asPackage).	
		self classes: aPackage classes asOrderedCollection.
		aPackage classes asOrderedCollection ]
		ifNil: [ #() ] ]
	
]

{ #category : #api }
OntoPharoUI >> extractConcepts [
	"Extract Classes Names Concepts"
	^ [ :selectedClass | 
	selectedClass 
	ifNotNil: [ 
		aClass := selectedClass.
		tfs splitName: aClass asString ]
	ifNil:[ #() ] ]

]

{ #category : #api }
OntoPharoUI >> extractInstanceVariables [
	"Extract Instance Variables from a Class"
	^ [ :selectedClass | 
	selectedClass 
	ifNotNil: [ 
	instanceVariableTFS classInstanceVariables: selectedClass ]
	ifNil: [ #() ] ]
]

{ #category : #api }
OntoPharoUI >> extractMethods [
	"Extract Methods from a given Class"
	^ [ :selectedClass | 
		selectedClass 
		ifNotNil:[
		methodTFS classAllMethodsNames: selectedClass]	
		ifNil: [ #() ] ]
]

{ #category : #api }
OntoPharoUI >> getSelectedConcept [
	"Get the selected Concept fril the conceptListPrenter"
	^ conceptListPresenter
		displayValueAt: conceptListPresenter selection selectedIndex
]

{ #category : #api }
OntoPharoUI >> getSelectedConceptIndex [
	"Get the selected Concept fril the conceptListPrenter"
	^ conceptListPresenter
		displayValueAt: conceptListPresenter selection selectedIndex
]

{ #category : #api }
OntoPharoUI >> getSelectedSuggestion [
	"get the selected suggestion from the suggestionPreseneter"
	
	suggestionPresenter selection selectedIndex ~= 0
	ifTrue:[^ suggestionPresenter
		displayValueAt: suggestionPresenter selection selectedIndex].
	^bgramClassSuggestionPresenter
	displayValueAt: bgramClassSuggestionPresenter selection selectedIndex.
]

{ #category : #initialization }
OntoPharoUI >> initializePresenters [

	tfs := TermsFeatureSelector new.
	methodTFS := MethodTermsFeatureSelector new.
	instanceVariableTFS := InstanceVariableFeatureSelector new.
	packageListPresenter := self newList headerTitle: 'Packages'.
	classListPresenter := self newList headerTitle: 'Class Names'.
	instanceVariablePresenter := self newList headerTitle: 'Instance Variables Names'.
	methodListPresenter := self newList headerTitle: 'Methods Names'.
	conceptListPresenter := self newList headerTitle: 'Class Name Concepts'.
	suggestionPresenter := self newList headerTitle: 'Class Name Suggestions'.
	bgramClassSuggestionPresenter := self newList headerTitle: 'Class Name Bgram Suggestions'.
	checkBoxMethod := self newCheckBox label: 'OntoPharo Methods Names'.
	checkBoxClass := self newCheckBox label: 'OntoPharo Classes Names'.
	checkBoxInstanceVar := self newCheckBox label: 'OntoPharo InstanceVariables Names'.
	checkBoxContext := self newCheckBox label: 'OntoPharo Context'. 
	checkBoxMain := self newCheckBox label: 'OntoPharo'.
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
		aPackage 
		ifNotNil:[
		(tfs proposeBigrams: aConcept in: (aPackage name)) collect: [ :index|
		(index history last, index last)]]
		ifNil:[#()]
		]
		
		
	
]

{ #category : #api }
OntoPharoUI >> proposeSuggestions [
	"Propose class Name suggestion based on the other classes concepts names"
	^ [ :aConcept | 
		aPackage 
		ifNotNil:[
		(tfs sortedConceptsByLevenshteinDistanceOf: aConcept in: aPackage )
		collect: #key ]
		ifNil: [ #() ] ]
		
	
]

{ #category : #refactoring }
OntoPharoUI >> refactorClassName: aClassNamed to: newName [  
	"Refactoring class Name to a new Name"
	(RBRefactoryChangeFactory instance renameClass: aClassNamed asClass to: newName) execute

]

{ #category : #refactoring }
OntoPharoUI >> replaceConcept: selectedConceptIndex with: selectedSuggestion [ 

	"This method replaces the selected concept in the tables with the selected suggestion"
	| selectedClass collectionWithSuggestion newName|
	newName := ''.
	selectedClass := classListPresenter  displayValueAt: (classListPresenter selection selectedIndex).	
			collectionWithSuggestion := (tfs splitName: selectedClass) at: selectedConceptIndex put: selectedSuggestion ; yourself.
			collectionWithSuggestion do:[:each| newName become: newName,each ].		
			^ newName
	
]

{ #category : #announcing }
OntoPharoUI >> selectClass: selectedClass [
	"Selects a Class in the UI."
	
	self selectPackage: selectedClass package.
	classListPresenter selectItem: selectedClass
	
]

{ #category : #announcing }
OntoPharoUI >> selectMethod: aMethod [
	"Selects a Method in the UI."
 
	| aMethodName |
	
	self selectClass: aMethod methodClass.
	aMethodName := aMethod name withoutPrefix: (aMethod methodClass name asString), '>>#'.
	methodListPresenter selectItem: aMethodName
	
]

{ #category : #announcing }
OntoPharoUI >> selectPackage: selectedPackage [
	"Selects aClass in the UI."
	
	packageListPresenter selectItem: selectedPackage packageName.

]
