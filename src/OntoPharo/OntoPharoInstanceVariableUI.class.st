"
OntoPharo for instance variables name suggestions execute 

	'OntoPharoInstanceVariableUI  open' to run it. 
"
Class {
	#name : #OntoPharoInstanceVariableUI,
	#superclass : #OntoPharoUI,
	#instVars : [
		'aClassInstanceVariables',
		'instanceVariableName',
		'instanceVariableNameBigramSuggestions'
	],
	#category : #'OntoPharo-Spec-UI'
}

{ #category : #specs }
OntoPharoInstanceVariableUI class >> defaultSpec [
	
	
	^ SpBoxLayout newVertical
	
		add:
			(SpBoxLayout newHorizontal 
				add: #classListPresenter ;
				add: #instanceVariablePresenter;
				add: #instanceVariableConceptPresenter;
				add: #instanceVariableNameSuggestion;
				add: #instanceVariableNameBigramSuggestions;
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
OntoPharoInstanceVariableUI class >> open [

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
OntoPharoInstanceVariableUI class >> title [ 
	^'OntoPharoInstanceVariableUI'
]

{ #category : #api }
OntoPharoInstanceVariableUI >> buttonHandler [
	"handels the Button Work"

	| newName selectedConceptIndex selectedSuggestion |
	selectedConceptIndex := self selectedConceptIndex.
	selectedSuggestion := self selectedSuggestion.
	newName := self
		replaceConcept: selectedConceptIndex
		with: selectedSuggestion.
	self refactorInstanceVariableName: instanceVariableName  to: newName
]

{ #category : #initialization }
OntoPharoInstanceVariableUI >> connectPresenters [
	super connectPresenters.
	classListPresenter
		transmitTo: instanceVariablePresenter
		transform: self extractInstanceVariables
		postTransmission: [ :destination | destination selectIndex: 1 ].
	instanceVariablePresenter
		transmitTo: instanceVariableConceptPresenter
		transform: self extractInstanceVariableConcepts
		postTransmission: [ :destination | destination selectIndex: 1 ].
	instanceVariableConceptPresenter
		transmitTo: instanceVariableNameSuggestion
		transform: self proposeInstancVariableSuggestions
		postTransmission: [ :destination | 
			destination selectIndex: 1.
			destination
				whenSelectionChangedDo: [ instanceVariableNameBigramSuggestions unselectAll ] ].
	instanceVariableConceptPresenter
		transmitTo: instanceVariableNameBigramSuggestions
		transform: self proposeInstancVariableBigramSuggestions
		postTransmission: [ :destination | 
			destination.
			destination
				whenSelectionChangedDo: [ instanceVariableNameSuggestion unselectAll ] ].
	button action: [ self buttonHandler ]
]

{ #category : #api }
OntoPharoInstanceVariableUI >> extractInstanceVariableConcepts [
	^ [ :instanceVariable | 
	instanceVariable
		ifNotNil: [
			instanceVariableName := instanceVariable.
			 instanceVariableTFS splitName: instanceVariable ]
		ifNil: [ #() ] ]
]

{ #category : #initialization }
OntoPharoInstanceVariableUI >> initializePresenters [ 

	super initializePresenters.
	instanceVariableConceptPresenter := self newList headerTitle:  'Instance Variable Concepts'.
	instanceVariableNameSuggestion := self newList headerTitle: 'Instance Variable Name Suggestions'.
	instanceVariableNameBigramSuggestions := self newList headerTitle: 'Instance Variable Bigrams Name Suggestions'.
	
]

{ #category : #api }
OntoPharoInstanceVariableUI >> proposeInstancVariableBigramSuggestions [
		"Propose Bigrams suggestions for Classes Names"
	^ [ :aConcept | 
		aConcept
		ifNotNil:[
		instanceVariableTFS proposeBigrams: aConcept in: (aPackage name).
		instanceVariableTFS reject:[:bgramConcept|
			((bgramConcept history last ~= aConcept) & (self selectedConceptIndex = instanceVariableConceptPresenter items size))] 
		thenCollect: [ :bgramConcept| 
				self replaceConcept: (self selectedConceptIndex) with: (bgramConcept history last).
				self replaceConcept: (self selectedConceptIndex + 1) with: (bgramConcept last)
				]]
		ifNil:[#()]
		].
]

{ #category : #api }
OntoPharoInstanceVariableUI >> proposeInstancVariableSuggestions [

		^ [ :aConcept | 
		aConcept ifNotNil: [ (instanceVariableTFS sortedConceptsByLevenshteinDistanceOf: aConcept in: (aPackage name))
			collect: #key ] ifNil: [ #() ]]
]

{ #category : #refactoring }
OntoPharoInstanceVariableUI >> refactorInstanceVariableName: anInstanceName to: aNewName [

	(RBRenameInstanceVariableRefactoring rename: anInstanceName to: aNewName in: aClass ) execute
]

{ #category : #refactoring }
OntoPharoInstanceVariableUI >> replaceConcept: selectedConceptIndex with: selectedSuggestion [ 

		"This method replaces the selected concept in the tables with the selected suggestion"
			|selectedInstanceVariable collectionWithSuggestion |
			
			selectedInstanceVariable := instanceVariablePresenter  displayValueAt: (instanceVariablePresenter selection selectedIndex).
			selectedInstanceVariable := methodListPresenter displayValueAt: (methodListPresenter selection selectedIndex).
			collectionWithSuggestion := (instanceVariableTFS splitName: selectedInstanceVariable) 	at:selectedConceptIndex put: selectedSuggestion ; yourself.
			^String streamContents: [:s | 
			collectionWithSuggestion do: [:each | s nextPutAll: each asString]]	
]

{ #category : #announcing }
OntoPharoInstanceVariableUI >> selectClass: selectedClass [
	"Selects a Class in the UI."
	
	aPackage := selectedClass package.
	aClass := selectedClass.
	self packages: RPackageOrganizer default packages.
	self selectPackage: selectedClass package.
	classListPresenter selectItem: selectedClass.
	
]

{ #category : #api }
OntoPharoInstanceVariableUI >> selectedConcept [
	^ instanceVariableConceptPresenter 
		displayValueAt: instanceVariableConceptPresenter selection selectedIndex
]

{ #category : #api }
OntoPharoInstanceVariableUI >> selectedConceptIndex [
	^ instanceVariableConceptPresenter selection selectedIndex
]

{ #category : #api }
OntoPharoInstanceVariableUI >> selectedSuggestion [

	instanceVariableNameSuggestion  selection selectedIndex ~= 0
	ifTrue:[^ instanceVariableNameSuggestion 
		displayValueAt: instanceVariableNameSuggestion  selection selectedIndex].	
	^instanceVariableNameBigramSuggestions displayValueAt: 
	instanceVariableNameBigramSuggestions selection selectedIndex.
]
