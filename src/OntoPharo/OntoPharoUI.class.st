Class {
	#name : #OntoPharoUI,
	#superclass : #SpPresenter,
	#instVars : [
		'notebook',
		'checkbox',
		'dynamicPage'
	],
	#category : 'OntoPharo-UI'
}

{ #category : #specs }
OntoPharoUI class >> defaultSpec [
	^ SpBoxLayout newVertical
		  add: #notebook;
		  add: (SpBoxLayout newHorizontal
				   add: #checkbox
				   withConstraints: [ :constraints | constraints width: 20 ];
				   add: 'Show dynamic presenter')
		  withConstraints: [ :constraints | 
		  constraints height: self labelHeight ];
		  yourself
]

{ #category : #specs }
OntoPharoUI class >> run [
	<script>
	self new openWithSpec
]

{ #category : #pages }
OntoPharoUI >> browserPage [
	^ SpNotebookPage
		  title: 'Browser'
		  icon: (self iconNamed: #nautilusIcon)
		  provider: [ 
			  SpClassMethodBrowser new
				  classes: self class environment allClasses;
				  yourself ] 
]

{ #category : #initialization }
OntoPharoUI >> connectPresenters [ 
	super connectPresenters.

	checkbox whenActivatedDo: [ notebook addPage: (dynamicPage := self dynamicPage) ].

	checkbox
		whenDeactivatedDo: [ dynamicPage
				ifNotNil: [ :page | 
					notebook removePage: page.
					dynamicPage := nil ] ]

]

{ #category : #pages }
OntoPharoUI >> dynamicPage [ 
	^ SpNotebookPage title: 'Dynamic' icon: (self iconNamed: #nautilusIcon) provider: [ SpDynamicWidgetChange new ]

]

{ #category : #initialization }
OntoPharoUI >> initializePresenters [
	notebook := self newNotebook.
	checkbox := self newCheckBox.
	notebook
		addPage: self objectClassPage;
		addPage: self objectInspectorPage;
		addPage: self browserPage
]

{ #category : #pages }
OntoPharoUI >> objectClassPage [ 
	^ SpNotebookPage title: 'Object class' icon: (self iconNamed: #nautilusIcon) provider: [ MessageBrowser new messages: Object methods ]



]

{ #category : #pages }
OntoPharoUI >> objectInspectorPage [ 
	^ SpNotebookPage
		title: 'Object inspector'
		icon: (self iconNamed: #nautilusIcon)
		provider: [ EyeInspector new
				inspect: Object;
				yourself ]
		layoutSpec: #inspectorSpec

]
