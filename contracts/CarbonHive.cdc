import NonFungibleToken from "./standard/NonFungibleToken.cdc"

pub contract CarbonHive: NonFungibleToken {

    pub event ContractInitialized()
    pub event FundingRoundCreated(id: UInt32, projectID: UInt32, name: String)
    pub event ReportCreated(id: UInt32, projectID: UInt32)
    pub event ProjectCreated(id: UInt32, name: String)
    pub event FundingRoundAddedToProject(projectID: UInt32, fundingRoundID: UInt32)
    pub event ReportAddedToProject(projectID: UInt32, reportID: UInt32)
    pub event CompletedFundingRound(projectID: UInt32, fundingRoundID: UInt32, numImpacts: UInt32)
    pub event ProjectClosed(projectID: UInt32)
    pub event ImpactMinted(impactID: UInt64, projectID: UInt32, fundingRoundID: UInt32, serialNumber: UInt32)
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event ImpactDestroyed(id: UInt64)


    access(self) var projectDatas: {UInt32: ProjectData}
    access(self) var fundingRoundDatas: {UInt32: FundingRoundData}
    access(self) var reportDatas: {UInt32: ReportData}
    access(self) var projects: @{UInt32: Project}

    pub let ImpactCollectionStoragePath: StoragePath
    pub let ImpactCollectionPublicPath: PublicPath
    pub let AdminStoragePath: StoragePath
    
    pub var nextFundingRoundID: UInt32
    pub var nextProjectID: UInt32
    pub var nextReportID: UInt32
    pub var totalSupply: UInt64

    pub struct FundingRoundData {
        pub let fundingRoundID: UInt32
        pub let name: String
        pub let description: String
        pub let formula: String
        pub let formulaType: String
        pub let unit: String
        pub let timePeriod: String
        pub let fundingRoundGoal: UInt32
        pub let fundingRoundEndTime: Fix64
        pub let projectID: UInt32
        pub let reports: [UInt32]
        pub let metadata: {String: String}

        init(
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
            pre {
                name != "": "New fundingRound name cannot be empty"
            }
            self.fundingRoundID = CarbonHive.nextFundingRoundID
            self.name = name
            self.description = description
            self.formula = formula
            self.formulaType = formulaType
            self.unit = unit
            self.timePeriod = timePeriod
            self.fundingRoundGoal = fundingRoundGoal
            self.fundingRoundEndTime = fundingRoundEndTime
            self.projectID = projectID
            self.reports = []
            self.metadata = metadata
            CarbonHive.nextFundingRoundID = CarbonHive.nextFundingRoundID + (1 as UInt32)
            emit FundingRoundCreated(id: self.fundingRoundID, projectID: projectID, name: name)
        }
    }

    pub struct ProjectData {
        pub let projectID: UInt32
        pub var fundingRounds: [UInt32]
        pub var fundingRoundCompleted: {UInt32: Bool}
        pub var closed: Bool
        pub var name: String
        pub var projectOwner: String
        pub var description: String
        pub var location: String
        pub var gis: String
        pub var projectType: String
        pub var reports: [UInt32]
        pub var metadata: { String: String}
        pub var impactMintedPerFundingRound: {UInt32: UInt32}

        init(
            fundingRounds: [UInt32],
            fundingRoundCompleted: {UInt32: Bool},
            closed: Bool,
            metadata: { String: String},
            name: String,
            projectOwner: String,
            description: String,
            location: String,
            gis: String,
            projectType: String,
            reports: [UInt32],
            impactMintedPerFundingRound: {UInt32: UInt32}
        ) {
            pre {
                name != "": "New project name cannot be empty"
            }
            self.projectID = CarbonHive.nextProjectID
            self.fundingRounds = fundingRounds
            self.fundingRoundCompleted = fundingRoundCompleted
            self.closed = closed
            self.metadata = metadata
            self.name = name
            self.projectOwner = projectOwner
            self.description = description
            self.location = location
            self.gis = gis
            self.projectType = projectType
            self.reports = reports
            self.impactMintedPerFundingRound = impactMintedPerFundingRound

            CarbonHive.nextProjectID = CarbonHive.nextProjectID + (1 as UInt32)

            emit ProjectCreated(id: self.projectID, name: name)
        }
    }

    pub struct ReportData {
        pub let reportID: UInt32
        pub let date: String
        pub let projectID: UInt32
        pub let fundingRoundID: UInt32
        pub let description: String
        pub let reportContent: String
        pub let reportContentType: String
        pub let metadata: {String: String}

        init(
            date: String,
            projectID: UInt32,
            fundingRoundID: UInt32,
            description: String,
            reportContent: String,
            reportContentType: String,
            metadata: {String: String}
        ) {
            self.reportID = CarbonHive.nextReportID
            self.date = date
            self.projectID = projectID
            self.fundingRoundID = fundingRoundID
            self.description = description
            self.reportContent = reportContent
            self.reportContentType = reportContentType
            self.metadata = metadata
            CarbonHive.nextReportID = CarbonHive.nextReportID + (1 as UInt32)
            emit ReportCreated(id: self.reportID, projectID: projectID)
        }
    }


    // Admin can call the Project resoure's methods to add FundingRound,
    // add Report and Mint Impact.
    //
    // Project can have zero to many FundingRounds and Reports.
    //
    // Impact NFT belogs to the project that minted it, and references the actual FundingRound
    // the Impact was minted for.
    pub resource Project {
        pub let projectID: UInt32
        pub var fundingRounds: [UInt32]
        pub var fundingRoundCompleted: {UInt32: Bool}
        pub var closed: Bool
        pub var metadata: { String: String}
        pub var name: String
        pub var projectOwner: String
        pub var description: String
        pub var location: String
        pub var gis: String
        pub var projectType: String
        pub var reports: [UInt32]
        pub var impactMintedPerFundingRound: {UInt32: UInt32}

        init(
            name: String,
            description: String,
            projectOwner: String,
            projectType: String,
            location: String,
            gis: String,
            metadata: {String: String}
        ) {
            self.projectID = CarbonHive.nextProjectID
            self.fundingRounds = []
            self.reports = []
            self.fundingRoundCompleted = {}
            self.closed = false
            self.impactMintedPerFundingRound = {}
            self.metadata = metadata
            self.projectType = projectType
            self.name = name
            self.description = description
            self.projectOwner = projectOwner
            self.location = location
            self.gis = gis

            CarbonHive.projectDatas[self.projectID] = ProjectData(
                fundingRounds: self.fundingRounds,
                fundingRoundCompleted: self.fundingRoundCompleted,
                closed: self.closed,
                metadata: metadata,
                name: name,
                projectOwner: projectOwner,
                description: description,
                location: location,
                gis: gis,
                projectType: projectType,
                reports: self.reports,
                impactMintedPerFundingRound: self.impactMintedPerFundingRound
            )
        }

        pub fun addReport(reportID: UInt32) {
            pre {
                CarbonHive.reportDatas[reportID] != nil: "Cannot add the Report to Project: Report doesn't exist."
            }
            self.reports.append(reportID)
            emit ReportAddedToProject(projectID: self.projectID, reportID: reportID)
        }

        pub fun addFundingRound(fundingRoundID: UInt32) {
            pre {
                CarbonHive.fundingRoundDatas[fundingRoundID] != nil: "Cannot add the FundingRound to Project: FundingRound doesn't exist."
                !self.closed: "Cannot add the FundingRound to the Project after the Project has been closed."
                self.impactMintedPerFundingRound[fundingRoundID] == nil: "The FundingRound has already beed added to the Project."
            }

            self.fundingRounds.append(fundingRoundID)
            self.fundingRoundCompleted[fundingRoundID] = false
            self.impactMintedPerFundingRound[fundingRoundID] = 0
            emit FundingRoundAddedToProject(projectID: self.projectID, fundingRoundID: fundingRoundID)
        }

        pub fun completeFundingRound(fundingRoundID: UInt32) {
            pre {
                self.fundingRoundCompleted[fundingRoundID] != nil: "Cannot complete the FundingRound: FundingRound doesn't exist in this Project!"
            }

            if !self.fundingRoundCompleted[fundingRoundID]! {
                self.fundingRoundCompleted[fundingRoundID] = true

                emit CompletedFundingRound(
                    projectID: self.projectID,
                    fundingRoundID: fundingRoundID,
                    numImpacts: self.impactMintedPerFundingRound[fundingRoundID]!
                )
            }
        }

        pub fun completeAllFundingRound() {
            for fundingRound in self.fundingRounds {
                self.completeFundingRound(fundingRoundID: fundingRound)
            }
        }

        pub fun close() {
            if !self.closed {
                self.closed = true
                emit ProjectClosed(projectID: self.projectID)
            }
        }

        pub fun mintImpact(
            fundingRoundID: UInt32,
            amount: UInt32,
            gis: String,
            timePeriod: String
        ): @NFT {
            pre {
                CarbonHive.fundingRoundDatas[fundingRoundID] != nil: "Cannot mint the Impact: This FundingRound doesn't exist."
                !self.fundingRoundCompleted[fundingRoundID]!: "Cannot mint the Impact from this FundingRound: This FundingRound has been completed."
            }

            let block = getCurrentBlock()
            let time = Fix64(block.timestamp)
            let fundingRound = CarbonHive.fundingRoundDatas[fundingRoundID]!
            if fundingRound.fundingRoundEndTime < time {
                panic("The funding round ended on ".concat(fundingRound.fundingRoundEndTime.toString()).concat(" now: ").concat(block.timestamp.toString()))
            }

            let numInFundingRound = self.impactMintedPerFundingRound[fundingRoundID]!
            if fundingRound.fundingRoundGoal == numInFundingRound {
                panic("The funding round ended, goal reached: ".concat(fundingRound.fundingRoundGoal.toString()).concat(" impact minted"))
            } 

            let newImpact: @NFT <- create NFT(
                projectID: self.projectID,
                fundingRoundID: fundingRoundID,
                serialNumber: numInFundingRound + (1 as UInt32),
                amount: amount, 
                gis: gis,
                timePeriod: timePeriod
            )

            self.impactMintedPerFundingRound[fundingRoundID] = numInFundingRound + (1 as UInt32)

            return <-newImpact
        }
    }


    pub struct ImpactData {
        pub let projectID: UInt32
        pub let fundingRoundID: UInt32
        pub let serialNumber: UInt32
        pub let amount: UInt32
        pub let gis: String
        pub let timePeriod: String

        init(
            projectID: UInt32,
            fundingRoundID: UInt32,
            serialNumber: UInt32,
            amount: UInt32,
            gis: String,
            timePeriod: String
        ) {
            self.projectID = projectID
            self.fundingRoundID = fundingRoundID
            self.serialNumber = serialNumber
            self.amount = amount
            self.gis = gis
            self.timePeriod = timePeriod
        }
    }

    pub resource NFT: NonFungibleToken.INFT {
        pub let id: UInt64 
        pub let data: ImpactData

        init(
            projectID: UInt32,
            fundingRoundID: UInt32,
            serialNumber: UInt32,
            amount: UInt32,
            gis: String,
            timePeriod: String
        ) {
            CarbonHive.totalSupply = CarbonHive.totalSupply + (1 as UInt64)
            self.id = CarbonHive.totalSupply
            self.data = ImpactData(
                projectID: projectID,
                fundingRoundID: fundingRoundID,
                serialNumber: serialNumber,
                amount: amount,
                gis: gis,
                timePeriod: timePeriod
            )

            emit ImpactMinted(
                impactID: self.id,
                projectID: self.data.projectID,
                fundingRoundID: self.data.fundingRoundID,
                serialNumber: self.data.serialNumber
            )
        }

        destroy() {
            emit ImpactDestroyed(id: self.id)
        }
    }

    pub resource ProjectAdmin {

        pub fun createFundingRound(
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
        ): UInt32 {
            var newFundingRound = FundingRoundData(
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
            let newID = newFundingRound.fundingRoundID
            CarbonHive.fundingRoundDatas[newID] = newFundingRound
            return newID
        }

        pub fun createReport(
            date: String,
            projectID: UInt32,
            fundingRoundID: UInt32,
            description: String,
            reportContent: String,
            reportContentType: String,
            metadata: {String: String}
        ): UInt32 {
            var newReport = ReportData(
                date: date,
                projectID: projectID,
                fundingRoundID: fundingRoundID,
                description: description,
                reportContent: reportContent,
                reportContentType: reportContentType,
                metadata: metadata
            )
            let newID = newReport.reportID
            CarbonHive.reportDatas[newID] = newReport
            return newID
        }

        pub fun createProject(
            name: String, 
            description: String, 
            projectOwner: String, 
            projectType: String, 
            location: String, 
            gis: String, 
            metadata: {String: String}
        ) {
            var newProject <- create Project(
                name: name,
                description: description,
                projectOwner: projectOwner,
                projectType: projectType,
                location: location,
                gis: gis,
                metadata: metadata
            )
            CarbonHive.projects[newProject.projectID] <-! newProject
        }

        pub fun borrowProject(projectID: UInt32): &Project {
            pre {
                CarbonHive.projects[projectID] != nil: "Cannot borrow Project: The Project doesn't exist"
            }
            return &CarbonHive.projects[projectID] as &Project
        }

        pub fun createNewAdmin(): @ProjectAdmin {
            return <-create ProjectAdmin()
        }
    }

    pub resource interface ImpactCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun batchDeposit(tokens: @NonFungibleToken.Collection)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowImpact(id: UInt64): &CarbonHive.NFT? {
            post {
                (result == nil) || (result?.id == id): 
                    "Cannot borrow Impact reference: The ID of the returned reference is incorrect"
            }
        }
    }

    pub resource Collection: ImpactCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic { 

        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init() {
            self.ownedNFTs <- {}
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) 
                ?? panic("Cannot withdraw: Impact does not exist in the collection")
            emit Withdraw(id: token.id, from: self.owner?.address)
            return <-token
        }

        pub fun batchWithdraw(ids: [UInt64]): @NonFungibleToken.Collection {
            var batchCollection <- create Collection()
            for id in ids {
                batchCollection.deposit(token: <-self.withdraw(withdrawID: id))
            }
            return <-batchCollection
        }

        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @CarbonHive.NFT
            let id = token.id
            let oldToken <- self.ownedNFTs[id] <- token
            if self.owner?.address != nil {
                emit Deposit(id: id, to: self.owner?.address)
            }
            destroy oldToken
        }

        pub fun batchDeposit(tokens: @NonFungibleToken.Collection) {
            let keys = tokens.getIDs()
            for key in keys {
                self.deposit(token: <-tokens.withdraw(withdrawID: key))
            }
            destroy tokens
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        pub fun borrowImpact(id: UInt64): &CarbonHive.NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                return ref as! &CarbonHive.NFT
            } else {
                return nil
            }
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <-create CarbonHive.Collection()
    }

    pub fun getProjectData(projectID: UInt32): {String: String}? {
        return self.projectDatas[projectID]?.metadata
    }


    pub fun getFundingRoundsInProject(projectID: UInt32): [UInt32]? {
        return CarbonHive.projects[projectID]?.fundingRounds
    }

    pub fun getReportsInProject(projectID: UInt32): [UInt32]? {
        return CarbonHive.projects[projectID]?.reports
    }

    init() {
        self.ImpactCollectionPublicPath = /public/ImpactCollection
        self.ImpactCollectionStoragePath = /storage/ImpactCollection
        self.AdminStoragePath = /storage/CarbonHiveAdmin

        self.projectDatas = {}
        self.fundingRoundDatas = {}
        self.reportDatas = {}
        self.projects <- {}

        self.totalSupply = 0
        self.nextFundingRoundID = 1
        self.nextProjectID = 1
        self.nextReportID = 1

        self.account.save<@Collection>(<- create Collection(), to: self.ImpactCollectionStoragePath)
        self.account.link<&{ImpactCollectionPublic}>(self.ImpactCollectionPublicPath, target: self.ImpactCollectionStoragePath)
        self.account.save<@ProjectAdmin>(<- create ProjectAdmin(), to: self.AdminStoragePath)

        emit ContractInitialized()
    }
}