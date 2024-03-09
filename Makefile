default: output_files/minimal_nrom.rbf

output_files/minimal_nrom.rbf: minimal_nrom.v mapper.sdc minimal_nrom.qpf minimal_nrom.qsf minimal_nrom_assignment_defaults.qdf
	@echo "\t Analysis & Synthesis"
	@quartus_map --read_settings_files=on --write_settings_files=off minimal_nrom -c minimal_nrom >quartus_output.txt
	@echo "\t Fitter (Place & Route)"
	@quartus_fit --read_settings_files=off --write_settings_files=off minimal_nrom -c minimal_nrom >>quartus_output.txt
	@echo "\t Assembler (Generate programming files)"
	@quartus_asm --read_settings_files=off --write_settings_files=off minimal_nrom -c minimal_nrom >>quartus_output.txt

.PHONY: everdrive

everdrive: output_files/minimal_nrom.rbf
	@echo "\t Copying to Everdrive N8 Pro"
	@edlink-n8 -cp output_files/minimal_nrom.rbf sd:/minimal_nrom/
	@echo ""