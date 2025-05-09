#!/bin/bash
set -e

test_site_path="./test/php-test-site"
test_files="./test/tests/"

echo "Encrypted Execution test files"
s_php tok-php-transformer.php -p $test_site_path
s_php tok-php-transformer.php -p $test_files --replace




cd $test_site_path

php -S localhost:8000 &
pid=$!
sleep 5

function test_failure {
	echo $1 >&2
	exit 1
}

curl http://localhost:8000/ | grep -q "Parse error"

if curl -f http://localhost:8000/ | grep -q "Parse error" ; then
	echo "SUCCESS: Vanilla site reached and returned syntax error." 
else
	 test_failure "FAILED: Non Encrypted site ran without syntax error -- encryption failed"
fi
kill $pid 

cd -
echo "Testing Changes Made"
if cmp -s $test_site_path"/index.php" $test_site_path"_ps/index.php"; then
	test_failure "FAILED: No differences found between index files."
else 
	echo "SUCCESS. Index files have been changed."
fi

if php -l $test_site_path/index.php; then
	test_failure "FAILED: Vanilla PHP ran successfully locally."
else
	echo "SUCCESS: Vannilla PHP threw syntax error locally."
fi

if php -l $test_site_path"_ps"; then
	echo "SUCCESS: Encrypted PHP ran successfully locally."
else 
	"FAILED: Encrypted PHP did not run successfully lcoally."
fi

cd $test_site_path"_ps"
echo "testing encrypted"
php -S localhost:8000 &
sleep 5

if curl -f  http://localhost:8000/; then
	if curl -f http://localhost:8000/ | grep -q "Parse error"; then
	       test_failure "FAILED: Encrypted Site reached, but Parse Error was Thrown."
       else
	       echo "SUCCESS: Encrypted site reached."
	fi
else
	test_failure "FAILED: Encrypted site could not be reached."
fi
cd -
for file in $test_files 
do
	if php -l $file; then
		echo "SUCCES: " $file
	else 
		test_failure "FAILURE: " $file
	fi
done	
