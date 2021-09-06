import CarbonHive from 0xf8d6e0586b0a20c7


pub fun main(reportID: UInt32): CarbonHive.ReportData? {

    let reportData = CarbonHive.getReportData(reportID: reportID) ?? panic("Report doesn't exist")

    log(reportData)

    return reportData
}