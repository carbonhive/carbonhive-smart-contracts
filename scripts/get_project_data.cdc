import CarbonHive from 0xf8d6e0586b0a20c7


pub fun main(projectID: UInt32): CarbonHive.ProjectData? {

    let projectData = CarbonHive.getProjectData(projectID: projectID) ?? panic("Project doesn't exist")

    log(projectData)

    return projectData
}