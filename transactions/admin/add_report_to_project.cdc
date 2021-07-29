import CarbonHive from 0xf8d6e0586b0a20c7

transaction(
            date: String,
            projectID: UInt32,
            fundingRoundID: UInt32,
            description: String,
            reportContent: String,
            reportContentType: String,
            metadata: {String: String}
) {

    // Local variable for the Admin object
    let adminRef: &CarbonHive.Admin
    let currReportID: UInt32

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&CarbonHive.Admin>(from: /storage/CarbonHiveAdmin)
            ?? panic("Could not borrow a reference to the Admin resource")
        self.currReportID = CarbonHive.nextReportID;
    }

    execute { 
        let reportID = self.adminRef.createReport(
                                            date: date,
                                            projectID: projectID,
                                            fundingRoundID: fundingRoundID,
                                            description: description,
                                            reportContent: reportContent,
                                            reportContentType: reportContentType,
                                            metadata: metadata
                                        )
        let projectRef = self.adminRef.borrowProject(projectID: projectID)
        projectRef.addReport(reportID: reportID)
    }

    post {
        CarbonHive.getReportsInProject(projectID: projectID)!.contains(self.currReportID): 
            "Project does not contain reportID"
    }
}
