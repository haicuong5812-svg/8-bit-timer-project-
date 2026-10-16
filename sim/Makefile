
#Define
TEST_NAME       ?=  
TB_NAME=tb_cnt_tmr
INCDIR=../test_case/
include test.list
 
 
 
#######################################
 
#cmd run: make TEST_NAME=test_xxx
#cmd run all: make regress_core
#cmt open waveform:  make waveform TEST_NAME=test_xxx
 
all: clean gen_testcase build run check_log
 
 
build:
	mkdir -p log
	mkdir -p wave
	vlib work
	vmap work work
	vlog -f compile.f
 
run: 
	vsim.exe -l log/$(TEST_NAME).log -voptargs=+acc -novopt -c ${TB_NAME} -do "log -r /*;run -all;"
	@mv vsim.wlf wave/$(TEST_NAME).wlf
	# Check simulation exit status (QuestaSim's own exit code)
	
check_log:
	@if ! grep -q "Error:" log/$(TEST_NAME).log; then \
		echo "#Simulation: @@@@@@@@@@@@" | tee -a  log/$(TEST_NAME).log; \
		echo "#Simulation: @@@ PASS @@@" | tee -a  log/$(TEST_NAME).log; \
		echo "#Simulation: @@@@@@@@@@@@" | tee -a  log/$(TEST_NAME).log; \
		echo "#Simulation for $(TEST_NAME) PASSED."; \
		echo "#==================================="; \
	else \
		echo "#Simulation: @@@@@@@@@@@@" | tee -a  log/$(TEST_NAME).log; \
		echo "#Simulation: @@@ FAIL @@@ (Errors found in log)" | tee -a  log/$(TEST_NAME).log; \
		echo "#Simulation: @@@@@@@@@@@@" | tee -a  log/$(TEST_NAME).log; \
		echo "#Simulation for $(TEST_NAME) FAILED (Errors found in log)."; \
		echo "#==================================="; \
	fi; \
	
waveform:
	vsim.exe -i -view wave/$(TEST_NAME).wlf &
 
gen_testcase:
	cp -rf ../test_case/$(TEST_NAME).v ../test_case/testcase.v
 
clean:
	rm -rf work
	rm -rf *.ini
	rm -rf *.log
	rm -rf *wlf*
	rm -rf *.ucdb

	rm -rf ../test_case/testcase.v
	rm -rf regress_report.list

	rm -rf *.txt
 
#cmd run: make regress_core
 
regress_core:
	for i in ${REGRESSION_LIST}; do \
	echo $$i ; \
	make "TEST_NAME=$$i"; \
	done
	make report  
 
report:
	@rm -f regress_report.list
	@for i in ${REGRESSION_LIST}; do \
	    echo -n $$i " : " >> regress_report.list; \
	    sed -n -e '/@@@ PASS @@@/p' log/$$i.log >> regress_report.list ;\
	    sed -n -e '/@@@ FAIL @@@/p' log/$$i.log >> regress_report.list ;\
	done
	@cat regress_report.list
 
#cmd run: make run_cov TEST_NAME=test_xxx
 
run_cov: gen_testcase
	mkdir -p coverage
	vlog.exe -coveropt 3 +cover +acc +incdir+$(INCDIR) -f compile.f
	vsim.exe -coverage -l log/cov_log.log -c ${TB_NAME} -voptargs="+cover=bcesfx" -novopt -assertdebug -do "coverage save -onexit coverage/${TEST_NAME}.ucdb; log -r /*;run -all"
 
gencov:
	vcover.exe merge sumary.ucdb $(REGRESSION_LIST:%=coverage/%.ucdb)
	vcover.exe report sumary.ucdb -file coverage/sumary_rp.txt
	vcover.exe report -zeros -details -code bcefsx -All -codeAll sumary.ucdb -file coverage/details_rp.txt
	vcover.exe report -html sumary.ucdb -htmldir html
 
#cmd run: make regress_cov

 
regress_cov:
	make build
	for i in ${REGRESSION_LIST}; do \
	echo $$i ; \
	make run_cov "TEST_NAME=$$i"; \
	done
	make gencov
