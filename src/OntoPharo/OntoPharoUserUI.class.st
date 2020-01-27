Class {
	#name : #OntoPharoUserUI,
	#superclass : #OntoPharoUI,
	#instVars : [
		'aClassMethods',
		'aClassInstanceVariables',
		'methodNameSuggestionPresenter',
		'instaceVariableNameSuggestion'
	],
	#category : #'OntoPharo-UI'
}

{ #category : #specs }
OntoPharoUserUI class >> defaultSpec [
	
	
	^ SpBoxLayout newVertical
	
		add:
			(SpBoxLayout newHorizontal 
				add: #methodListPresenter;
				add: #conceptListPresenter;
				add: #suggestionPresenter;			
				yourself);
		add:
			(SpBoxLayout newHorizontal 
				add: #questionLabel ;
				add: #button;
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
	"windowPresenter window extent: 800@600."
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
OntoPharoUserUI >> connectPresenters [


	super connectPresenters.
	methodListPresenter 
	transmitTo: conceptListPresenter 
	transform: self extractMethodConcepts
	postTransmission: [ :destination | destination selectIndex: 1 ].
	conceptListPresenter
	transmitTo: suggestionPresenter
	transform: self proposeMethodSuggestions
	postTransmission: [ :destination | destination selectIndex: 1 ].
]

{ #category : #initialization }
OntoPharoUserUI >> extractClassNameConcepts [


]

{ #category : #initialization }
OntoPharoUserUI >> extractMethodConcepts [
	^[:aMethodName|
		methodTfs splitName: aMethodName.
	 ]
]

{ #category : #initialization }
OntoPharoUserUI >> initializePresenter [

	super initializePresenter.
	conceptListPresenter headerTitle: 'Method Name Suggestions'.
	suggestionPresenter headerTitle: 'Method name Suggestion'.
	instaceVariableNameSuggestion := self newList headerTitle: 'Instance Variable Name Suggestions'.

]

{ #category : #initialization }
OntoPharoUserUI >> proposeInstancVariableSuggestions [
]

{ #category : #initialization }
OntoPharoUserUI >> proposeMethodSuggestions [
		^ [ :aConcept | 
		(methodTfs sortedConceptsByLevenshteinDistanceOf: aConcept in: (aPackage name))
			collect: #key ]
		
]
