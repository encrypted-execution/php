SAVEDIR=$1

if [ ! -d "${ENCRYPTED_EXECUTION_PATH}/${SAVEDIR}" ]; then
    mkdir $ENCRYPTED_EXECUTION_PATH/$SAVEDIR
    cp $PHP_SRC_PATH/Zend/zend_language_scanner.l /usr/local/bin/encrypted-execution/$SAVEDIR/zend_language_scanner.l
    cp $PHP_SRC_PATH/Zend/zend_language_parser.y /usr/local/bin/encrypted-execution/$SAVEDIR/zend_language_parser.y
    cp $PHP_SRC_PATH/ext/phar/phar.php /usr/local/bin/encrypted-execution/$SAVEDIR/phar.php
    cp $PHP_SRC_PATH/ext/phar/build_precommand.php /usr/local/bin/encrypted-execution/$SAVEDIR/build_precommand.php
fi

