import CarbonHive from 0xf8d6e0586b0a20c7

transaction(
    name: String,
    description: String,
    formula: String,
    formulaType: String,
    unit: String,
    timePeriod: String,
    fundingRoundGoal: UInt32,
    fundingRoundEndTime: Fix64,
    projectID: UInt32,
    metadata: {String: String}
) {

    // Local variable for the ProjectAdmin object
    let adminRef: &CarbonHive.ProjectAdmin
    let currFundingRoundID: UInt32

    prepare(acct: AuthAccount) {

        // borrow a reference to the ProjectAdmin resource in storage
        self.adminRef = acct.borrow<&CarbonHive.ProjectAdmin>(from: /storage/CarbonHiveAdmin)
            ?? panic("Could not borrow a reference to the ProjectAdmin resource")
        self.currFundingRoundID = CarbonHive.nextFundingRoundID;
    }

    execute { 
        let fundingRoundID = self.adminRef.createFundingRound(
                                            name: name,
                                            description: description,
                                            formula: formula,
                                            formulaType: formulaType,
                                            unit: unit,
                                            timePeriod: timePeriod,
                                            fundingRoundGoal: fundingRoundGoal,
                                            fundingRoundEndTime: fundingRoundEndTime,
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
