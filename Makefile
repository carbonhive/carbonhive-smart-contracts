all: demo

#run the demo script on devnet
.PHONY: demo
demo: deploy
	go run ./tasks/demo/main.go

#this goal deployes all the contracts to emulator
.PHONY: deploy
deploy:
	flow project deploy  -n emulator --update
