Class {
	#name : #TermsFeatureSelectorByContext,
	#superclass : #TermsFeatureSelector,
	#instVars : [
		'packagesByContext',
		'classesByContext',
		'methodsByContext',
		'instanceVriablesByContext'
	],
	#category : #'OntoPharo-Name-Filtrer'
}

{ #category : #'as yet unclassified' }
TermsFeatureSelectorByContext >> initialize [ 
 super initialize.
 packagesByContext := OrderedCollection new.
]

{ #category : #'as yet unclassified' }
TermsFeatureSelectorByContext >> packagesByContext [
	^packagesByContext 

]

{ #category : #'as yet unclassified' }
TermsFeatureSelectorByContext >> packagesByPrefix: aPrefix [

	^ self systemAllPackagesNames select: [ :packageName | |packagePrefix|
	packagePrefix := (self splitName: packageName ) first.
	packagePrefix = aPrefix ] .
]

{ #category : #'as yet unclassified' }
TermsFeatureSelectorByContext >> packagesClassesByContext: prefix [ 

	"Packages Classes in a given context"
	|packagesByPrefix|
	packagesByPrefix := self packagesByPrefix: prefix.
	
	classesByContext := packagesByPrefix flatCollect: [ :aPackage|
		 (self packageAllClassesNames: aPackage). ].
	^classesByContext
]

{ #category : #'as yet unclassified' }
TermsFeatureSelectorByContext >> packagesInstanceVariablesByContext: prefix [

	"Packages Instance variables in a given context"
	| classesByPrefix |
	classesByPrefix := self packagesClassesByContext: prefix.
	instanceVriablesByContext := classesByPrefix flatCollect: [ :each | each asClass instVarNames].
	^ instanceVriablesByContext
]

{ #category : #'as yet unclassified' }
TermsFeatureSelectorByContext >> packagesMethodsByContext: prefix [

	"Packages Methods in a given context " 
	|classesByPrefix|
	classesByPrefix := self packagesClassesByContext: prefix. 
	methodsByContext := classesByPrefix flatCollect: [ :each|
		each asClass methods].
	^methodsByContext
]

{ #category : #'as yet unclassified' }
TermsFeatureSelectorByContext >> systemAllPackagesByContext [

	"get all packages of the same context, based on prefix 'Pharo naming convention' "
	|prefixes |
	prefixes := self systemAllPackagesPrefixes asOrderedCollection . 
	prefixes collect: [ :prefix|
   packagesByContext add: (self packagesByPrefix: prefix ) asOrderedCollection].
	^packagesByContext 

]

{ #category : #'as yet unclassified' }
TermsFeatureSelectorByContext >> systemAllPackagesNames [

 ^self systemAllPackages collect: [:packageName| packageName name asString].
	
]

{ #category : #'as yet unclassified' }
TermsFeatureSelectorByContext >> systemAllPackagesPrefixes [
	|allPackagesNames |
	
	allPackagesNames := self systemAllPackagesNames.

	^(allPackagesNames collect:  [:packageName|
		 (self splitName: packageName) first]) asSet. 
]
