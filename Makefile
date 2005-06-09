############################
# Change the task name!
############################
TASK = Alignment_sim_twist

include /data/mta4/MTA/include/Makefile.MTA

BIN  = alignment_sim_twist_extract.perl alignment_sim_twist_extract_acadata.perl alignment_sim_twist_fid_trend_plots.perl alignment_sim_twist_remove_dupl.perl alignment_sim_twist_wrap_script alignment_sim_twist_main_script alignment_sim_twist_relation_plot.perl alignment_sim_twist_extract_plot_only.perl
DOC  = README

install:
ifdef BIN
	rsync --times --cvs-exclude $(BIN) $(INSTALL_BIN)/
endif
ifdef DATA
	mkdir -p $(INSTALL_DATA)
	rsync --times --cvs-exclude $(DATA) $(INSTALL_DATA)/
endif
ifdef DOC
	mkdir -p $(INSTALL_DOC)
	rsync --times --cvs-exclude $(DOC) $(INSTALL_DOC)/
endif
ifdef IDL_LIB
	mkdir -p $(INSTALL_IDL_LIB)
	rsync --times --cvs-exclude $(IDL_LIB) $(INSTALL_IDL_LIB)/
endif
ifdef CGI_BIN
	mkdir -p $(INSTALL_CGI_BIN)
	rsync --times --cvs-exclude $(CGI_BIN) $(INSTALL_CGI_BIN)/
endif
ifdef PERLLIB
	mkdir -p $(INSTALL_PERLLIB)
	rsync --times --cvs-exclude $(PERLLIB) $(INSTALL_PERLLIB)/
endif
ifdef WWW
	mkdir -p $(INSTALL_WWW)
	rsync --times --cvs-exclude $(WWW) $(INSTALL_WWW)/
endif
