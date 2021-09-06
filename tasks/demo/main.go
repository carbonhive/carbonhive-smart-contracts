package main

import (
	"fmt"

	"github.com/bjartek/go-with-the-flow/gwtf"
	"github.com/onflow/cadence"
)

func main() {

	flow := gwtf.NewGoWithTheFlowEmulator()
	fmt.Println("Demo of Carbonhive")
	flow.CreateAccount("carbonhive", "partner", "buyer1", "buyer2")

	key := cadence.NewString("someKey")
	value := cadence.NewString("some value")
	keyValue := []cadence.KeyValuePair{{Key: key, Value: value}}
	metadata := cadence.NewDictionary(keyValue)

	flow.TransactionFromFile("admin/create_project").
		SignProposeAndPayAsService().
		StringArgument("name").
		StringArgument("description").
		StringArgument("url").
		StringArgument("developer").
		StringArgument("type").
		StringArgument("location").
		StringArgument("locationDescriptor").
		Argument(metadata).
		RunPrintEventsFull()

	keyFr := cadence.NewString("name")
	valueFr := cadence.NewString("Round 1")
	keyValueFr := []cadence.KeyValuePair{{Key: keyFr, Value: valueFr}}
	metadataFr := cadence.NewDictionary(keyValueFr)

	flow.TransactionFromFile("admin/add_fundingRound_to_project").
		SignProposeAndPayAsService().
		StringArgument("name").
		StringArgument("description").
		StringArgument("formula").
		StringArgument("formulaType").
		StringArgument("unit").
		StringArgument("vintagePeriod").
		UInt32Argument(100).
		Fix64Argument("1923881437.00000000").
		StringArgument("location").
		StringArgument("locationDescriptor").
		UInt32Argument(1).
		Argument(metadataFr).
		RunPrintEventsFull()

	flow.TransactionFromFile("user/setup_account").
		SignProposeAndPayAs("buyer1").
		RunPrintEventsFull()

	flow.TransactionFromFile("admin/mint_impact").
		SignProposeAndPayAsService().
		AccountArgument("buyer1").
		UInt32Argument(1).
		UInt32Argument(1).
		UInt32Argument(40).
		StringArgument("location").
		StringArgument("locationDescriptor").
		StringArgument("vintagePeriod").
		StringArgument("contentData").
		StringArgument("contentType").
		RunPrintEventsFull()

	keyRep := cadence.NewString("reportdata")
	valueRep := cadence.NewString("some data")
	keyValueRep := []cadence.KeyValuePair{{Key: keyRep, Value: valueRep}}
	metadataRep := cadence.NewDictionary(keyValueRep)

	flow.TransactionFromFile("admin/add_report_to_project").
		SignProposeAndPayAsService().
		StringArgument("date").
		UInt32Argument(1).
		UInt32Argument(1).
		StringArgument("description").
		StringArgument("reportContent").
		StringArgument("reportContentType").
		Argument(metadataRep).
		RunPrintEventsFull()

	keyRep2 := cadence.NewString("reportdata2")
	valueRep2 := cadence.NewString("some other data")
	keyValueRep2 := []cadence.KeyValuePair{{Key: keyRep2, Value: valueRep2}}
	metadataRep2 := cadence.NewDictionary(keyValueRep2)

	flow.TransactionFromFile("admin/add_report_to_fundingRound").
		SignProposeAndPayAsService().
		StringArgument("date2").
		UInt32Argument(1).
		UInt32Argument(1).
		StringArgument("description2").
		StringArgument("reportContent2").
		StringArgument("reportContentType2").
		Argument(metadataRep2).
		RunPrintEventsFull()

	fundingRoundsInProject := flow.ScriptFromFile("get_fundingRounds_in_project").
		UInt32Argument(1).
		RunReturnsJsonString()
	fmt.Println(fundingRoundsInProject)

	flow.ScriptFromFile("get_reports_in_project").
		UInt32Argument(1).
		Run()

	flow.ScriptFromFile("get_project_data").
		UInt32Argument(1).
		Run()

	flow.ScriptFromFile("get_fundingRound_data").
		UInt32Argument(1).
		Run()

	flow.ScriptFromFile("get_reports_data").
		UInt32Argument(1).
		Run()

	flow.ScriptFromFile("get_reports_data").
		UInt32Argument(2).
		Run()

	flow.ScriptFromFile("get_collection_ids").
		AccountArgument("buyer1").
		Run()

	flow.ScriptFromFile("get_impact").
		AccountArgument("buyer1").
		UInt64Argument(1).
		Run()

	flow.ScriptFromFile("get_impact_content_data").
		AccountArgument("buyer1").
		UInt64Argument(1).
		Run()

	flow.ScriptFromFile("get_amount_used_in_fundingRound").
		UInt32Argument(1).
		UInt32Argument(1).
		Run()

	flow.ScriptFromFile("get_impact_content_data").
		AccountArgument("buyer2").
		UInt64Argument(1).
		Run()

}
