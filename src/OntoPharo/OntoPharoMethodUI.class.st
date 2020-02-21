"
OntoPharo for methods name suggestions execute 

	'OntoPharoMethodUI open' to run it. 
"
Class {
	#name : #OntoPharoMethodUI,
	#superclass : #OntoPharoUI,
	#instVars : [
		'aClassMethods',
		'aClassInstanceVariables',
		'methodNameSuggestionPresenter',
		'methodName',
		'methodConceptListPresenter',
		'methodSuggestionListPresenter',
		'methodBigramSuggestionListPresenter'
	],
	#category : #'OntoPharo-Spec-UI'
}

{ #category : #specs }
OntoPharoMethodUI class >> defaultSpec [
	
	
	^ SpBoxLayout newVertical
	
		add:
			(SpBoxLayout newHorizontal 
				add: #methodListPresenter;
				add: #methodConceptListPresenter;
				add: #methodSuggestionListPresenter ;	
				add: #methodBigramSuggestionListPresenter;		
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
				add: #button ;
				yourself) withConstraints: [ :constraints | constraints height: 30 ];
		yourself
		 
]

{ #category : #specs }
OntoPharoMethodUI class >> open [
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
OntoPharoMethodUI class >> title [ 
	^'OntoPharoMethodUI'
]

{ #category : #api }
OntoPharoMethodUI >> buttonHandler [
	"handels the Button Work"

	| newName selectedConceptIndex selectedSuggestion |
	selectedConceptIndex := self getSelectedConceptIndex.
	selectedSuggestion := self getSelectedSuggestion.
	newName := self
		replaceConcept: selectedConceptIndex
		with: selectedSuggestion.
	self refactorMethodName: methodName to: newName
]

{ #category : #initialization }
OntoPharoMethodUI >> connectPresenters [
	super connectPresenters.
	classListPresenter
		transmitTo: methodListPresenter
		transform: self extractMethods
		postTransmission: [ :destination | destination selectIndex: 1 ].
	methodListPresenter
		transmitTo: methodConceptListPresenter
		transform: self extractMethodConcepts
		postTransmission: [ :destination | destination selectIndex: 1 ].
	methodConceptListPresenter
		transmitTo: methodSuggestionListPresenter
		transform: self proposeMethodSuggestions
		postTransmission: [ :destination | 
			destination selectIndex: 1.
			destination
				whenSelectionChangedDo: [ methodBigramSuggestionListPresenter unselectAll ] ].
	methodConceptListPresenter
		transmitTo: methodBigramSuggestionListPresenter
		transform: self proposeMethodBigramsSuggestions
		postTransmission: [ :destination | destination.
			destination
				whenSelectionChangedDo: [ methodSuggestionListPresenter unselectAll ] ].
	button action: [ self buttonHandler ]
]

{ #category : #api }
OntoPharoMethodUI >> extractMethodConcepts [

	^[:aMethodName|
		aMethodName ifNotNil: [ 
			methodName := aMethodName.
			methodTFS splitName: aMethodName] 
		ifNil: [ #() ]
	 ]
]

{ #category : #api }
OntoPharoMethodUI >> getSelectedConcept [
	^ methodConceptListPresenter
		displayValueAt: methodConceptListPresenter selection selectedIndex
]

{ #category : #api }
OntoPharoMethodUI >> getSelectedConceptIndex [
	^ methodConceptListPresenter selection selectedIndex
]

{ #category : #api }
OntoPharoMethodUI >> getSelectedSuggestion [

	methodSuggestionListPresenter selection selectedIndex ~= 0
	ifTrue:[^ methodSuggestionListPresenter
		displayValueAt: methodSuggestionListPresenter selection selectedIndex].
	^methodBigramSuggestionListPresenter displayValueAt: 
	methodBigramSuggestionListPresenter selection selectedItem.
]

{ #category : #initialization }
OntoPharoMethodUI >> initializePresenter [

	super initializePresenter.
	methodConceptListPresenter := self newList headerTitle: 'Method Name Concepts'.
	methodSuggestionListPresenter := self newList  headerTitle: 'Method name Suggestions'.
	methodBigramSuggestionListPresenter := self newList headerTitle: 'Method name Bigrams Suggestions'

	
]

{ #category : #api }
OntoPharoMethodUI >> proposeMethodBigramsSuggestions [
		"Propose Bigrams suggestions for Classes Names"
	^ [ :aConcept | 
		
		aConcept ifNotNil: [ 
		(methodTFS proposeBigrams: aConcept in: (aPackage name)) 
			collect: [ :index | index history last, index last ]
		]ifNil: [ #() ] ].
]

{ #category : #api }
OntoPharoMethodUI >> proposeMethodSuggestions [
		^ [ :aConcept | 
	
		aConcept ifNotNil: [ 
		(methodTFS sortedConceptsByLevenshteinDistanceOf: aConcept in: (aPackage name))
			collect: #key ] ifNil: [ #() ] ]
		
]

{ #category : #refactoring }
OntoPharoMethodUI >> refactorMethodName: aMethodName to: aNewName [ 
	
	(RBRenameMethodRefactoring renameMethod: aMethodName asSymbol in: aClass to: aNewName  permutation: (1 to: 0) ) execute.
]

{ #category : #refactoring }
OntoPharoMethodUI >> replaceConcept: selectedConceptIndex with: selectedSuggestion [ 

		"This method replaces the selected concept in the tables with the selected suggestion"
			|selectedMethod collectionWithSuggestion newName|
			newName := ''.
			selectedMethod := methodListPresenter displayValueAt: (methodListPresenter selection selectedIndex).
			
			collectionWithSuggestion := (methodTFS splitName: selectedMethod) at:selectedConceptIndex put: selectedSuggestion ; yourself.
			collectionWithSuggestion do:[:each| newName become: newName,each ].		
			^ newName
]

{ #category : #announcing }
OntoPharoMethodUI >> selectMethod: aMethod [
	"Selects a Method in the UI."
 
	| aMethodName |
	
	aPackage := (aMethod methodClass) package.
	aClass := aMethod methodClass.
	self packages: RPackageOrganizer default packages.
	self selectClass: aMethod methodClass.
	aMethodName := aMethod name withoutPrefix: (aMethod methodClass name asString), '>>#'.
	methodListPresenter selectItem: aMethodName
	
]
