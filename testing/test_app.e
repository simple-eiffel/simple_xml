note
	description: "Test application for simple_xml"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_APP

create
	make

feature -- Initialization

	make
			-- Run tests.
		local
			l_tests: LIB_TESTS
		do
			print ("Running simple_xml tests...%N")
			print ("=============================%N%N")
			create l_tests
			run_test (agent l_tests.test_parse_simple, "test_parse_simple")
			run_test (agent l_tests.test_text_at, "test_text_at")
			run_test (agent l_tests.test_attr_at, "test_attr_at")
			run_test (agent l_tests.test_elements_at, "test_elements_at")
			run_test (agent l_tests.test_element_navigation, "test_element_navigation")
			run_test (agent l_tests.test_builder_simple, "test_builder_simple")
			run_test (agent l_tests.test_builder_nested, "test_builder_nested")
			run_test (agent l_tests.test_modification, "test_modification")
			run_test (agent l_tests.test_parse_error, "test_parse_error")
			run_test (agent l_tests.test_to_string, "test_to_string")
			print ("%N=============================%N")
			print ("Tests completed: " + test_count.out + " total, ")
			print (pass_count.out + " passed, ")
			print ((test_count - pass_count).out + " failed%N")
		end

feature {NONE} -- Implementation

	test_count: INTEGER
	pass_count: INTEGER

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run single test with error handling.
		local
			l_failed: BOOLEAN
		do
			if not l_failed then
				test_count := test_count + 1
				a_test.call (Void)
				pass_count := pass_count + 1
				print ("  [PASS] " + a_name + "%N")
			end
		rescue
			l_failed := True
			print ("  [FAIL] " + a_name + "%N")
			retry
		end

end
