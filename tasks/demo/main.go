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
		StringArgument("projectOwner").
		StringArgument("projectType").
		StringArgument("location").
		StringArgument("gis").
		Argument(metadata).
		RunPrintEventsFull()

	keyFr := cadence.NewString("name")
	valueFr := cadence.NewString("Round 1")
	keyValueFr := []cadence.KeyValuePair{{Key: keyFr, Value: valueFr}}
	metadataFr := cadence.NewDictionary(keyValueFr)

	flow.TransactionFromFile("admin/add_funding_round_to_project").
		SignProposeAndPayAsService().
		StringArgument("name").
		StringArgument("description").
		StringArgument("formula").
		StringArgument("formulaType").
		StringArgument("unit").
		StringArgument("timePeriod").
		UInt32Argument(1).
		Fix64Argument("1923881437.00000000").
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
		UInt32Argument(1).
		StringArgument("gis").
		StringArgument("timePeriod").
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
}
