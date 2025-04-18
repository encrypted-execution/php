<?php
/**
 * Copyright (c) 2020 Polyverse Corporation
 */

include 'snip-transform.php';
$long_opts = array("replace", "test", "dump", "phar", "inc", "dictionary:", "memory_limit::");

set_error_handler("error_handle", E_USER_ERROR);

$replace = false;
$dump = false;
$extensions = array("php");
$root_path = "";
$out = "";
$num_ps = 0;
$is_snip = false;
$is_test = false;
$dictionary_path=null;



arg_parse(getopt("s:p:d:", $long_opts));

if ($is_snip ) {
    echo ee_snip($out, $is_test, $dictionary_path);
    return;
}


echo "Encrypt " . $root_path . " to " . $out, PHP_EOL;

if (!is_dir($out))
{
    encrypt($root_path, $out);
    return;
} else {
    $iterator = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($root_path, FilesystemIterator::SKIP_DOTS),
        RecursiveIteratorIterator::SELF_FIRST);

    foreach ($iterator as $fileInfo) {
        $fileOut = str_replace($root_path, $out, $fileInfo);
        if (in_array(pathinfo($fileInfo, PATHINFO_EXTENSION), $extensions)) {
            if ($dump) {
                echo "Encrypting $fileInfo \n";
            }
            encrypt($fileInfo, $fileOut);
            $num_ps++;
        } else if (is_dir($fileOut)) {
            continue;
        } else if ($fileInfo->isDir() && !$replace) {
            mkdir($fileOut);
        } else if (!$replace) {
            copy($fileInfo, $fileOut);
        }
    }
}

echo "Done. Encrypted " . $num_ps . " files\n";

function arg_parse($opts)
{
    global $dump, $root_path, $out, $replace, $is_snip, $dictionary_path;

    if (array_key_exists("memory_limit", $opts)) {
        $memory_limit = $opts["memory_limit"];
        echo "Setting memory limit to: " . $memory_limit . "\n";
        ini_set('memory_limit', $memory_limit);
    }

    if (array_key_exists("s", $opts) && array_key_exists("p", $opts)) {
        trigger_error("Cannot encrypt both path and snip.", E_USER_ERROR);
    }

    if (array_key_exists("s", $opts)) {
        $is_snip = true;
        $out = $opts['s'];
        return;
    }

    if (!array_key_exists("p", $opts)) {
        trigger_error("Missing required argument: '-p'", E_USER_ERROR);
    }

    //Parse
    $replace = array_key_exists("replace", $opts);
    $dump = array_key_exists("dump", $opts);

    if (array_key_exists("dictionary", $opts)) {
        $dictionary_path = $opts["dictionary"];
    } else if (array_key_exists("d", $opts)) {
        $dictionary_path = $opts["d"];
    }

    get_ext($opts);

    //Path handle
    $root_path = rtrim($opts['p'], '/');

    if (file_exists($root_path)) {
        $out = $replace ? $root_path : get_out_root($root_path);
    } else {
        trigger_error("Invalid path or file.", E_USER_ERROR);
    }
}

function get_out_root($root)
{
    $path_out = pathinfo($root, PATHINFO_DIRNAME) . "/" . pathinfo($root, PATHINFO_FILENAME) . "_ps";

    if (is_dir($root)) {
        if (!is_dir($path_out)) {
            mkdir($path_out);
        }
        return $path_out;
    } else {
        return $path_out . "." . pathinfo($root, PATHINFO_EXTENSION);
    }
}

function get_ext($opts)
{
    global $extensions, $is_test;
    if (array_key_exists("test", $opts)) { $is_test=true; array_push($extensions, "phpt"); }
    if (array_key_exists("inc", $opts)) { array_push($extensions, "inc"); }
    if (array_key_exists("phar", $opts)) { array_push($extensions, "phar"); }
}

function encrypt($file_name, $fileOut)
{
    // ignore symlinks
    if (is_link($file_name)) { return; }

    global $is_test, $dictionary_path;
    $file_str = file_get_contents($file_name);
    $fp = fopen($fileOut, 'w');
    fwrite($fp, ee_snip($file_str, $is_test, $dictionary_path));
    fclose($fp);
}

function error_handle($errno, $errstr) {
    echo "Error: [$errno] $errstr\n";
    echo "Failing.";
    die();
}
