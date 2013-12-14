" Vim Syntax file for rtorrent.rc
" Author: Chris Carpita <ccarpita@gmail.com>
" Version: 0.1
" Revised: May, 2008

if exists("b:current_syntax")
    finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn match rtorrentComment "#.*$"

syn keyword rtorrentSetting bind check_hash close_low_diskspace close_untied contained create_link cwd delete_link dht dht_add_node dht_port directory download_rate enable_trackers encoding_list encryption handshake_log hash_interval hash_max_tries hash_read_ahead http_cacert http_capath http_proxy import ip key_layout load load_start load_start_verbose load_verbose max_downloads_div max_downloads_global max_file_size max_memory_usage max_open_files max_open_http max_open_sockets max_peers max_peers_seed max_uploads max_uploads_div max_uploads_global min_peers min_peers_seed on_close on_erase on_finished on_hash_done on_hash_queued on_hash_removed on_insert on_open on_start on_stop peer_exchange port_random port_range receive_buffer_size remove_untied safe_sync schedule schedule_remove send_buffer_size session session_lock session_on_completion session_save split_file_size split_suffix start_tied stop_on_ration stop_untied throttle_down throttle_ip throttle_up tos tracker_dump tracker_numwant try_import umask upload_rate use_udp_trackers view_add view_sort view_sort_current view_sort_new

syn match rtorrentOp "=" contained

syn match rtorrentStatement "\s*\w\+\s*=\s*.*$" contains=rtorrentSettingAttempt,rtorrentOp

syn match rtorrentSettingAttempt "^\s*\w\+" contains=rtorrentSetting contained

hi link rtorrentSettingAttempt String
hi link rtorrentStatement Type
hi link rtorrentComment Comment
hi link rtorrentSetting Operator
hi link rtorrentOp	   Special

let b:current_syntax = "rtorrent"

let &cpo = s:cpo_save
unlet s:cpo_save
