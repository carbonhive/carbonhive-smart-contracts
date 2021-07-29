import CarbonHive from 0xf8d6e0586b0a20c7

transaction(
    name: String,
    description: String,
    formula: String,
    formulaType: String,
    unit: String,
    vintagePeriod: String,
    totalAmount: UInt32,
    roundEnds: Fix64,
    location: String,
    locationDescriptor: String,
    projectID: UInt32,
    metadata: {String: String}
) {

    // Local variable for the Admin object
    let adminRef: &CarbonHive.Admin
    let currFundingRoundID: UInt32

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&CarbonHive.Admin>(from: /storage/CarbonHiveAdmin)
            ?? panic("Could not borrow a reference to the Admin resource")
        self.currFundingRoundID = CarbonHive.nextFundingRoundID;
    }

    execute { 
        let fundingRoundID = self.adminRef.createFundingRound(
                                            name: name,
                                            description: description,
                                            formula: formula,
                                            formulaType: formulaType,
                                            unit: unit,
                                            vintagePeriod: vintagePeriod,
                                            totalAmount: totalAmount,
                                            roundEnds: roundEnds,
                                            location: location,
                                            locationDescriptor: locationDescriptor,
                                            projectID: projectID,
                                            metadata: metadata
                                        )
        let projectRef = self.adminRef.borrowProject(projectID: projectID)
        projectRef.addFundingRound(fundingRoundID: fundingRoundID)
    }

    post {
        CarbonHive.getFundingRoundsInProject(projectID: projectID)!.contains(self.currFundingRoundID): 
            "Project does not contain fundingRoundID"
    }
}
