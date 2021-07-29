import CarbonHive from 0xf8d6e0586b0a20c7


pub fun main(projectID: UInt32): [UInt32]? {

    let reports = CarbonHive.getReportsInProject(projectID: projectID) ?? panic("Project doesn't exist")

    log(reports)

    return reports
}