Class {
	#name : #OntoPharoMethodUI,
	#superclass : #OntoPharoUI,
	#instVars : [
		'aClassMethods',
		'aClassInstanceVariables',
		'methodNameSuggestionPresenter',
		'methodName',
		'methodConceptListPresenter',
		'methodSuggestionListPresenter'
	],
	#category : #'OntoPharo-UI'
}

{ #category : #specs }
OntoPharoMethodUI class >> defaultSpec [
	
	
	^ SpBoxLayout newVertical
	
		add:
			(SpBoxLayout newHorizontal 
				add: #methodListPresenter;
				add: #methodConceptListPresenter;
				add: #methodSuggestionListPresenter ;			
				yourself);
		add: 
		(SpBoxLayout newHorizontal 
				add: #questionLabel ;
				add: #button ;
				yourself) withConstraints: [ :constraints | constraints height: 30 ];
		yourself
		 
]

{ #category : #specs }
OntoPharoMethodUI class >> title [ 
	^'OntoPharoMethodUI'
]

{ #category : #initialization }
OntoPharoMethodUI >> buttonHandler [
	"handels the Button Work"

	| newName selectedConcept selectedSuggestion |
	selectedConcept := self getSelectedConcept.
	selectedSuggestion := self getSelectedSuggestion.
	newName := self
		replaceConcept: selectedConcept
		with: selectedSuggestion.
	self refactorMethodName: methodName to: newName
]

{ #category : #initialization }
OntoPharoMethodUI >> connectPresenters [

	super connectPresenters.
	
	methodListPresenter
	transmitTo: methodConceptListPresenter 
	transform: self extractMethodConcepts
	postTransmission: [ :destination | destination selectIndex: 1].
	methodConceptListPresenter
	transmitTo: methodSuggestionListPresenter
	transform: self proposeMethodSuggestions
	postTransmission: [ :destination | destination selectIndex: 1].
	
	button
		action: [ self buttonHandler]
]

{ #category : #initialization }
OntoPharoMethodUI >> extractMethodConcepts [

	^[:aMethodName|
		aMethodName ifNotNil: [ 
			methodName := aMethodName.
			methodTFS splitName: aMethodName] 
		ifNil: [ #() ]
	 ]
]

{ #category : #initialization }
OntoPharoMethodUI >> getSelectedConcept [
	^ methodConceptListPresenter
		displayValueAt: methodConceptListPresenter selection selectedIndex
]

{ #category : #initialization }
OntoPharoMethodUI >> getSelectedSuggestion [

	^ methodSuggestionListPresenter
		displayValueAt: methodSuggestionListPresenter selection selectedIndex
]

{ #category : #initialization }
OntoPharoMethodUI >> initializePresenter [

	super initializePresenter.
	
	methodConceptListPresenter := self newList headerTitle: 'Method Name Concepts'.
	methodSuggestionListPresenter := self newList  headerTitle: 'Method name Suggestions'.

	
]

{ #category : #initialization }
OntoPharoMethodUI >> proposeMethodSuggestions [
		^ [ :aConcept | 
	
		aConcept ifNotNil: [ 
		(methodTFS sortedConceptsByLevenshteinDistanceOf: aConcept in: (aPackage name))
			collect: #key ] ifNil: [ #() ] ]
		
]

{ #category : #initialization }
OntoPharoMethodUI >> refactorMethodName: aMethodName to: aNewName [ 
	
	(RBRenameMethodRefactoring renameMethod: aMethodName asSymbol in: aClass to: aNewName  permutation: (1 to: 0) ) execute.
]

{ #category : #initialization }
OntoPharoMethodUI >> replaceConcept: selectedConcept with: selectedSuggestion [ 

		"This method replaces the selected concept in the tables with the selected suggestion"
			|selectedMethod |
			selectedMethod := methodListPresenter displayValueAt: (methodListPresenter selection selectedIndex).
			^ selectedMethod copyReplaceAll: selectedConcept with: selectedSuggestion.   
]
