Class {
	#name : #OntoPharoUI,
	#superclass : #SpPresenter,
	#instVars : [
		'dynamicPage',
		'conceptListPresenter',
		'classListPresenter',
		'suggestionPresenter',
		'tfs',
		'button',
		'aPackage',
		'packageListPresenter',
		'questionLabel',
		'aClassName'
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
	windowPresenter window extent: 800@600.
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

{ #category : #initialization }
OntoPharoUI >> buttonHundler [

			|selectedSuggestion selectedConcept selectedClass |
			selectedSuggestion := suggestionPresenter displayValueAt: (suggestionPresenter selection selectedIndex).
			selectedConcept := conceptListPresenter displayValueAt: (conceptListPresenter selection selectedIndex).
			selectedClass := classListPresenter displayValueAt: (classListPresenter selection selectedIndex).
			^ selectedClass copyReplaceAll: selectedConcept with: selectedSuggestion.  
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
		postTransmission: [ :destination | destination selectIndex: 1 ].
	button
		action: [ 
						|newName|
						newName := self buttonHundler.
						self refactorClassName: aClassName to: newName.
			]
]

{ #category : #initialization }
OntoPharoUI >> extractClasses [

	^ [ :aPackageName | 	
		aPackage := ((aPackageName asSymbol) asPackage).	
		self classes: ( aPackage classes asOrderedCollection).
		aPackage classes asOrderedCollection 
		]
]

{ #category : #initialization }
OntoPharoUI >> extractConcepts [
	^ [ :aClass | 
	"aPackage := aClass class package."
	aClassName := aClass name asString .
	tfs splitClassName: aClass getName asString ]
]

{ #category : #initialization }
OntoPharoUI >> initializePresenters [

	tfs := TermsFeatureSelector new.
	packageListPresenter := self newList headerTitle: 'Packages'.
	classListPresenter := self newList headerTitle: 'ClassNames'.
	conceptListPresenter := self newList headerTitle: 'Concepts'.
	suggestionPresenter := self newList headerTitle: 'Suggestions'.
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

{ #category : #initialization }
OntoPharoUI >> proposeSuggestions [
	^ [ :aConcept | 
		(tfs sortedConceptsByLevenshteinDistanceOf: aConcept in: (aPackage name))
			collect: #key ]
		
		
	
]

{ #category : #accessing }
OntoPharoUI >> refactorClassName: aClassNamed to: newName [  

"Refactoring class Name to a new Name"

(RBRefactoryChangeFactory instance renameClass: aClassNamed asClass to: newName) execute

]

{ #category : #initialization }
OntoPharoUI >> selectClass: aClass [

	"Selects aClass in the UI."
	| classIndex packageIndex|
	
	self selectPackage: aClass.
	
	classIndex := (classListPresenter items indexOf: aClass ifAbsent: [ self error: ('Class {1} not found' format: { aClass name }) ]).
	classListPresenter clickAtIndex: classIndex.
]

{ #category : #initialization }
OntoPharoUI >> selectClassNamed: aName [

	| index |
	index := (classListPresenter items  indexOf: aName ifAbsent: [^ self ]).
	classListPresenter clickAtIndex: index. 
]

{ #category : #initialization }
OntoPharoUI >> selectPackage: aClass [

	"Selects aClass in the UI."
	| packageIndex|
	
	packageIndex := (packageListPresenter items indexOf: (aClass package name asString)  ifAbsent: [ self error: ('Package {1} not found' format: { aClass package name }) ]).
	packageListPresenter clickAtIndex: packageIndex.
]
