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
	#category : #'OntoPharo-UI'
}

{ #category : #specs }
OntoPharoInstanceVariableUI class >> defaultSpec [
	
	
	^ SpBoxLayout newVertical
	
		add:
			(SpBoxLayout newHorizontal 
				add: #instanceVariablePresenter;
				add: #instanceVariableConceptPresenter;
				add: #instanceVariableNameSuggestion;
				add: #instanceVariableNameBigramSuggestions;
				yourself);
		add: 
		(SpBoxLayout newHorizontal 
				add: #questionLabel ;
				add: #button ;
				yourself) withConstraints: [ :constraints | constraints height: 30 ];
		yourself
		 
]

{ #category : #specs }
OntoPharoInstanceVariableUI class >> title [ 
	^'OntoPharoInstanceVariableUI'
]

{ #category : #api }
OntoPharoInstanceVariableUI >> buttonHandler [
	"handels the Button Work"

	| newName selectedConcept selectedSuggestion |
	selectedConcept := self getSelectedConcept.
	selectedSuggestion := self getSelectedSuggestion.
	newName := self
		replaceConcept: selectedConcept
		with: selectedSuggestion.
	self refactorInstanceVariableName: instanceVariableName  to: newName
]

{ #category : #initialization }
OntoPharoInstanceVariableUI >> connectPresenters [

	super connectPresenters.

	instanceVariablePresenter
	transmitTo: instanceVariableConceptPresenter
	transform: self extractInstanceVariableConcepts 
	postTransmission: [ :destination | destination selectIndex: 1].
	instanceVariableConceptPresenter
	transmitTo: instanceVariableNameSuggestion
	transform: self proposeInstancVariableSuggestions  
	postTransmission: [ :destination | destination selectIndex: 1].
	instanceVariableConceptPresenter
	transmitTo: instanceVariableNameBigramSuggestions 
	transform: self proposeInstancVariableBigramSuggestions  
	postTransmission: [ :destination | destination selectIndex: 1].
	
	button
		action: [ self buttonHandler]
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

{ #category : #api }
OntoPharoInstanceVariableUI >> getSelectedConcept [
	^ instanceVariableConceptPresenter 
		displayValueAt: instanceVariableConceptPresenter selection selectedIndex
]

{ #category : #api }
OntoPharoInstanceVariableUI >> getSelectedSuggestion [

	^ instanceVariableNameSuggestion 
		displayValueAt: instanceVariableNameSuggestion  selection selectedIndex
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
		(instanceVariableTFS proposeBigrams: aConcept in: (aPackage name)) collect: [ :index|
		(index history last, index last)
		 ]
		]
		
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
OntoPharoInstanceVariableUI >> replaceConcept: selectedConcept with: selectedSuggestion [ 

		"This method replaces the selected concept in the tables with the selected suggestion"
			|selectedInstanceVariable |
			selectedInstanceVariable := instanceVariablePresenter  displayValueAt: (instanceVariablePresenter selection selectedIndex).
			^ selectedInstanceVariable copyReplaceAll: selectedConcept with: selectedSuggestion.   
]
