"
am a Class responsible on extracting entities (Packages, Classes, Methods)  by context (based on smalltalk naming convention), execute this script to run an example of me:  

tfsc := TermsFeatureSelectorByContext new.
tfsc context: 'Onto'.
tfsc packagesClassesByContext.

"
Class {
	#name : #TermsFeatureSelectorByContext,
	#superclass : #TermsFeatureSelector,
	#instVars : [
		'packagesByContext',
		'classesByContext',
		'methodsByContext',
		'instanceVriablesByContext',
		'prefix',
		'aPackageConceptsCollection'
	],
	#category : #'OntoPharo-Name-Filtrer'
}

{ #category : #api }
TermsFeatureSelectorByContext >> context: aPrefix [
	
	prefix := aPrefix.
]

{ #category : #initialization }
TermsFeatureSelectorByContext >> initialize [ 
 super initialize.
 packagesByContext := OrderedCollection new.
 aPackageConceptsCollection := self packagesByContext flatCollect: [:each| self collectAllConcepts: each].
]

{ #category : #api }
TermsFeatureSelectorByContext >> packagesByContext [

	^ self systemAllPackages select: [ :aPackage | 
		|packageName packagePrefix|
	packageName := aPackage name asString.
	packagePrefix := (self splitName: packageName ) first.
	packagePrefix = prefix ] .
]

{ #category : #api }
TermsFeatureSelectorByContext >> packagesClassesByContext [ 

	"Packages Classes in a given context"
	
	classesByContext := self packagesByContext flatCollect: [ :aPackage| aPackage classes ].
	aPackageConceptsCollection := self packagesByContext flatCollect: [:each| self collectAllConcepts: each].
	^classesByContext asOrderedCollection 
]

{ #category : #api }
TermsFeatureSelectorByContext >> packagesInstanceVariablesByContext [
	"Packages Instance variables in a given context"

	| classesByPrefix |
	classesByPrefix := self packagesClassesByContext.
	instanceVriablesByContext := classesByPrefix
		flatCollect: [ :each | each instVarNames ].
	^ instanceVriablesByContext
]

{ #category : #api }
TermsFeatureSelectorByContext >> packagesMethodsByContext [

	"Packages Methods in a given context " 
	|classesByPrefix|
	classesByPrefix := self packagesClassesByContext. 
	methodsByContext := classesByPrefix flatCollect: [ :each|
		each methods].
	^methodsByContext collect:[:each| each name withoutPrefix: (each methodClass name asString), '>>#']
]

{ #category : #sorting }
TermsFeatureSelectorByContext >> sortedConceptsByHammingDistanceOF: aConcept in: collectionOfPackages [
	"Sort a Class Concept compared to other classes concepts in a given Package by Hamming distance"

	| aPackageConcepsCollection hammingCollection |
	aPackageConcepsCollection := collectionOfPackages flatCollect:[:aPackage| self collectAllConcepts: aPackage].
	hammingCollection := aPackageConcepsCollection
		reject: [ :anotherConcept | 
			(anotherConcept sameAs: aConcept )|(aConcept size ~= anotherConcept size)
			 ] 
		thenCollect: [ :anotherConcept | 
					anotherConcept
						-> 
							(termsMeasurments hammingDistanceOf: aConcept with: anotherConcept) ].

	^ self sort2DCollection: hammingCollection.
]

{ #category : #sorting }
TermsFeatureSelectorByContext >> sortedConceptsByLevenshteinDistanceOf: aConcept [

	"Sort a Class Concept compared to other classes concepts in a given context by Levenstein distance returning a key/value collection "
	|  levenshteinCollection|
	
	
	levenshteinCollection := aPackageConceptsCollection reject: [:anotherConcept| (anotherConcept sameAs: aConcept ) 	| ((termsMeasurments levenshteinDistanceOf: aConcept with: anotherConcept) >= 3) ] thenCollect: 
		 [ :anotherConcept| 
			anotherConcept
				->
					(termsMeasurments levenshteinDistanceOf: aConcept with: anotherConcept) 
				].
	^ self sort2DCollection: levenshteinCollection.
]

{ #category : #api }
TermsFeatureSelectorByContext >> systemAllPackagesNames [

 ^self systemAllPackages collect: [:packageName| packageName name asString].
	
]

{ #category : #api }
TermsFeatureSelectorByContext >> systemAllPackagesPrefixes [
	|allPackagesNames |
	
	allPackagesNames := self systemAllPackagesNames.

	^(allPackagesNames collect:  [:packageName|
		 (self splitName: packageName) first]) asSet. 
]
