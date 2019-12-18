running
setUp
	| trainPackage |
	tfs := TermsFeatureSelector new.
	trainPackage := tfs splitAllPackageClassesNames: 'BaselineOfZodiac'.
	tfs trainOn: trainPackage