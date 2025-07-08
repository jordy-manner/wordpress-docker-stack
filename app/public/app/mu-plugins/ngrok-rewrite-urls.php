<?php
/*
Plugin Name:  NGrok Rewrite Urls
Description:  Rewrite URLS when the Ngrok tunnel is used to expose your WordPress site to the internet.
Version:      1.0.0
*/

/**
 * Usage:
 * Add the following to your functions.php file:
    if(str_contains($_SERVER['HTTP_X_FORWARDED_HOST'], 'ngrok')) {
        if(
            isset($_SERVER['HTTP_X_FORWARDED_HOST']) &&
            $_SERVER['HTTP_X_FORWARDED_PROTO'] === "https"
        ) {
            $server_proto = 'https://';
        } else {
            $server_proto = 'http://';
        }

        define('WP_SITEURL', $server_proto . $_SERVER['HTTP_HOST']);
        define('WP_HOME', $server_proto . $_SERVER['HTTP_HOST']);
        define('LOCALTUNNEL_ACTIVE', true);
    }
 */

/**
 * @see https://matthewshields.co.uk/sharing-local-wordpress-sites-remotely-using-ngrok
 */



add_action('registered_taxonomy', function () {
    if(defined('LOCALTUNNEL_ACTIVE') && LOCALTUNNEL_ACTIVE === true) {
        ob_start(function ($page_html) {
            if(defined('LOCALTUNNEL_ACTIVE') && LOCALTUNNEL_ACTIVE === true) {

                $wp_home_url = esc_url(home_url('/'));
                $rel_home_url = wp_make_link_relative($wp_home_url);

                $esc_home_url = str_replace('/', '\/', $wp_home_url);
                $rel_esc_home_url = str_replace('/', '\/', $rel_home_url);

                $rel_page_html = str_replace($wp_home_url, $rel_home_url, $page_html);
                $esc_page_html = str_replace($esc_home_url, $rel_esc_home_url, $rel_page_html);

                return $esc_page_html;
            }
        });
    }
});
add_action('shutdown', function () {
    if(defined('LOCALTUNNEL_ACTIVE') && LOCALTUNNEL_ACTIVE === true) {
        @ob_end_flush();
    }
});