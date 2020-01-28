Class {
	#name : #OntoPharoUserUI,
	#superclass : #OntoPharoUI,
	#instVars : [
		'aClassMethods',
		'aClassInstanceVariables',
		'methodNameSuggestionPresenter',
		'methodName',
		'methodConceptListPresenter'
	],
	#category : #'OntoPharo-UI'
}

{ #category : #specs }
OntoPharoUserUI class >> defaultSpec [
	
	
	^ SpBoxLayout newVertical
	
		add:
			(SpBoxLayout newHorizontal 
				add: #methodListPresenter;
				add: #methodConceptListPresenter;
				add: #suggestionPresenter;			
				yourself);
		add:
			(SpBoxLayout newHorizontal 
				add: #instanceVariablePresenter;
				add: #instanceVariableConceptPresenter;
				add: #instanceVariableNameSuggestion;
				yourself);
		add: 
		(SpBoxLayout newHorizontal 
				add: #questionLabel ;
				add: #button ;
				yourself) withConstraints: [ :constraints | constraints height: 30 ];
		yourself
		 
]

{ #category : #specs }
OntoPharoUserUI class >> killRefresh [

	refresher unregister
]

{ #category : #specs }
OntoPharoUserUI class >> new [
	instance := super new. 
	refresher := OntoEventBroker new.
	refresher addUI: instance.
	^ instance
]

{ #category : #specs }
OntoPharoUserUI class >> open [
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
	windowPresenter window extent: 800@600.
	^ windowPresenter
]

{ #category : #specs }
OntoPharoUserUI class >> refresher [
	^ refresher
]

{ #category : #specs }
OntoPharoUserUI class >> title [ 
	^'OntoPharo User'
]

{ #category : #initialization }
OntoPharoUserUI >> buttonHandler [ 

		"handels the Button Work"
		
			| newName selectedConcept selectedSuggestion|
			selectedConcept := methodConceptListPresenter  displayValueAt: (methodConceptListPresenter selection selectedIndex).
			selectedSuggestion := suggestionPresenter displayValueAt: (suggestionPresenter selection selectedIndex).
			
			newName := self replaceConcept: selectedConcept with: selectedSuggestion.
	
			self refactorMethodName: methodName to: newName.
]

{ #category : #initialization }
OntoPharoUserUI >> connectPresenters [

	super connectPresenters.
	
	methodListPresenter
	transmitTo: methodConceptListPresenter 
	transform: self extractMethodConcepts
	postTransmission: [ :destination | destination selectIndex: 1].
	methodConceptListPresenter
	transmitTo: suggestionPresenter
	transform: self proposeMethodSuggestions
	postTransmission: [ :destination | destination selectIndex: 1].
	instanceVariablePresenter
	transmitTo: instanceVariableConceptPresenter
	transform: self extractInstanceVariableConcepts 
	postTransmission: [ :destination | destination selectIndex: 1].
	instanceVariableConceptPresenter
	transmitTo: instanceVariableNameSuggestion
	transform: self proposeInstancVariableSuggestions  
	postTransmission: [ :destination | destination selectIndex: 1].
	
	button
		action: [ self buttonHandler]
]

{ #category : #initialization }
OntoPharoUserUI >> extractInstanceVariableConcepts [
	^ [ :instanceVariable | 
	instanceVariable
		ifNotNil: [ instanceVariableTFS splitName: instanceVariable ]
		ifNil: [ #() ] ]
]

{ #category : #initialization }
OntoPharoUserUI >> extractMethodConcepts [

	^[:aMethodName|
		aMethodName ifNotNil: [ 
			methodName := aMethodName.
			methodTFS splitName: aMethodName] 
		ifNil: [ #() ]
	 ]
]

{ #category : #initialization }
OntoPharoUserUI >> initializePresenter [

	super initializePresenter.
	methodConceptListPresenter := self newList headerTitle: 'Method Name Concepts'.
	suggestionPresenter headerTitle: 'Method name Suggestions'.
	instanceVariableConceptPresenter := self newList headerTitle:  'Instance Variable Concepts'.
	instanceVariableNameSuggestion := self newList headerTitle: 'Instance Variable Name Suggestions'.
	
]

{ #category : #initialization }
OntoPharoUserUI >> proposeInstancVariableSuggestions [

		^ [ :aConcept | 
		aConcept ifNotNil: [ (instanceVariableTFS sortedConceptsByLevenshteinDistanceOf: aConcept in: (aPackage name))
			collect: #key ] ifNil: [ #() ]]
]

{ #category : #initialization }
OntoPharoUserUI >> proposeMethodSuggestions [
		^ [ :aConcept | 
	
		aConcept ifNotNil: [ 
		(methodTFS sortedConceptsByLevenshteinDistanceOf: aConcept in: (aPackage name))
			collect: #key ] ifNil: [ #() ] ]
		
]

{ #category : #initialization }
OntoPharoUserUI >> refactorMethodName: aMethodName in:  aClass to: aNewName [ 
	
	(RBRenameMethodRefactoring renameMethod: aMethodName asSymbol in: aClass  to: aNewName  permutation: (1 to: 0) ) execute.
]

{ #category : #initialization }
OntoPharoUserUI >> refactorMethodName: aMethodName to: aNewName [ 
	
	(RBRenameMethodRefactoring renameMethod: aMethodName asSymbol in: aClass to: aNewName  permutation: (1 to: 0) ) execute.
]

{ #category : #initialization }
OntoPharoUserUI >> replaceConcept: selectedConcept with: selectedSuggestion [ 

		"This method replaces the selected concept in the tables with the selected suggestion"
			|selectedMethod |
			selectedMethod := methodListPresenter displayValueAt: (methodListPresenter selection selectedIndex).
			^ selectedMethod copyReplaceAll: selectedConcept with: selectedSuggestion.   
]
