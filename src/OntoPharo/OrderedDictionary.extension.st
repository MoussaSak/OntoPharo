Extension { #name : #OrderedDictionary }

{ #category : #'*OntoPharo' }
OrderedDictionary >> sort [
    self sort: [ :a :b | a <= b ].

]

{ #category : #'*OntoPharo' }
OrderedDictionary >> sort: aBlock [
    | associationBlock |
    associationBlock := [ :a :b | aBlock value: a value value: b value ].
    self sortAssociations: associationBlock.
]

{ #category : #'*OntoPharo' }
OrderedDictionary >> sortAssociations: aBlock [
    | sortedAssociations |
    sortedAssociations := self associations sort: aBlock.
    self removeAll.
    self addAll: sortedAssociations.
]

{ #category : #'*OntoPharo' }
OrderedDictionary >> sortDescending [
    self sort: [ :a :b | a > b ].
]
