#!/bin/bash
# Copyright (c) 2020 Polyverse Corporation

copy_dependencies() {
        cp -n $PHP_EXEC/php $PHP_EXEC/s_php
        cp -n $PHP_EXEC/s_php $$ENCRYPTED_EXECUTION_PATH
        cp -n $PHP_SRC_PATH/ext/phar/phar.php $$ENCRYPTED_EXECUTION_PATH
        cp -n $PHP_SRC_PATH/Zend/zend_language_scanner.l $$ENCRYPTED_EXECUTION_PATH
        cp -n $PHP_SRC_PATH/Zend/zend_language_parser.y $$ENCRYPTED_EXECUTION_PATH

    
}

reset_php() {
        cp $ENCRYPTED_EXECUTION_PATH/phar.php $PHP_SRC_PATH/ext/phar/phar.php
        rm -f $PHP_SRC_PATH/Zend/zend_language_scanner.c
        rm -f $PHP_SRC_PATH/Zend/zend_language_parser.c
}

transform_lambda() {
        /runtime/bin/php tok-php-transformer.php -p /runtime --replace
        /runtime/bin/php tok-php-transformer.php -s "$(cat /runtime/bootstrap)" > /runtime/bootstrap
}

copy_dependencies

if [[ "$MODE" == "encrypted" || -f $$ENCRYPTED_EXECUTION_PATH ]]; then

        echo "===================== ENCRYPTED EXECUTION ENABLED =========================="
        echo "Setting up Encrypted Execution...."
	reset_php
        echo "Scrambling php source."
        ./php-scrambler

        echo "Recompiling encrypted PHP..."
        $PHP_EXEC/s_php tok-php-transformer.php -p $PHP_SRC_PATH/ext/phar/phar.php --replace

	cd $PHP_SRC_PATH;
        make -o ext/phar/phar.php install;

        cd $$ENCRYPTED_EXECUTION_PATH;

        echo "Transforming lambda files..."
        transform_lambda
        $PHP_EXEC/s_php tok-php-transformer.php -p ./phar.php --replace
else 
         echo "===================== ENCRYPTED EXECUTION  DISABLED =========================="
         echo "To enable Encrypted Execution set MODE = 'encrypted'"
fi
reset_php
