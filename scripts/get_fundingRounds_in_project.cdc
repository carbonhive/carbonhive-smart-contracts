import CarbonHive from 0xf8d6e0586b0a20c7


pub fun main(projectID: UInt32): [UInt32]? {

    let fundingRounds = CarbonHive.getFundingRoundsInProject(projectID: projectID) ?? panic("Project doesn't exist")

    log(fundingRounds)

    return fundingRounds
}