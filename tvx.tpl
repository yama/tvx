//<?php
/**
 * TVX
 *
 * リソース変数の値を分かりやすく出力
 * 
 * @category	snippet
 * @version 	0.1
 * @license 	http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @internal	@properties 
 * @internal	@modx_category Content
 */

$tvx = new TVX();
return $tvx->get_value();



class TVX
{
	function TVX()
	{
	}
	
	function get_value()
	{
		global $modx;
		
		if(is_array($modx->event->params)) $p = $modx->event->params;
		else                               $p['tv'] = 'pagetitle';
		
		switch($p['tv'])
		{
			case 'date':
			case 'pub_date':
			case 'unpub_date':
			case 'createdon':
			case 'editedon':
			case 'deletedon':
			case 'publishedon':
				if($p['tv']=='date')     $p['tv'] = $this->get_target_date();
				if(!isset($p['format'])) $p['format'] = $modx->toDateFormat(null, 'formatOnly') . ' %H:%M';
				$value = $this->mb_strftime($p['format'], $modx->documentObject[$p['tv']]);
				break;
			case 'title':
			case 'pagetitle':
			case 'longtitle':
				$value = $this->get_title_value($p['tv']);
				break;
			case 'author':
			case 'createdby':
			case 'editedby':
			case 'deletedby':
			case 'publishedby':
				if($p['tv']=='author')  $p['tv'] = 'createdby';
				if(!isset($p['field'])) $p['field']  = 'fullname';
				$value = $this->get_memberinfo($p['tv'],$p['field']);
				break;
			case 'description':
			case 'introtext':
				$value = $modx->documentObject[$p['tv']];
				break;
			default:
				if(!is_array($modx->documentObject[$p['tv']]))
				{
					$value = $modx->documentObject[$p['tv']];
				}
				elseif($modx->documentObject[$p['tv']][1])
				{
					$value = $modx->documentObject[$p['tv']][1];
				}
		}
		
		if($p['eval']) $value = $this->eval_str($value, $p['eval']);
		
		return $value;
	}
	
	function eval_str($value, $eval_code)
	{
		$eval_code = str_replace('$value', "'" . $value . "'", $eval_code);
		$eval_code = trim($eval_code,';') . ';';
		if(strpos($eval_code,'return ')===false) $eval_code = 'return ' . $eval_code;
		$value = eval($eval_code);
		return $value;
	}
	
	function get_target_date()
	{
		global $modx;
		
		if(empty($modx->documentObject['pub_date'])) $str = 'pub_date';
		else                                         $str = 'createdon';
		
		return $str;
	}
	
	function get_title_value($field_name)
	{
		global $modx;
		
		switch($field_name)
		{
			case 'pagetitle':
			case 'longtitle':
				$value = $modx->documentObject[$field_name];
				break;
			case 'title':
				if($modx->documentIdentifier == $modx->config['site_start'])
				{
					$value = '';
				}
				elseif(!empty($modx->documentObject['longtitle']))
				{
					 $value = $modx->documentObject['longtitle'];
				}
				else $value = $modx->documentObject['pagetitle'];
		}
		
		return $value;
	}
	
	function get_memberinfo($target, $field = '')
	{
		global $modx;
		
		if($field == '') $field = 'fullname';
		
		$memberid = $modx->documentObject[$target];
		
		if($memberid)
		{
			$info = $modx->getUserInfo($memberid);
			$str = $info[$field];
		}
		else $str = '-';
		
		return $str;
	}
	
	function mb_strftime($format = '', $timestamp = '')
	{
		global $modx;
		
		if($format == '') $format = $modx->toDateFormat(null, 'formatOnly') . ' %H:%M';
		
		if(method_exists($modx,'mb_strftime'))
		{
			$str = $modx->mb_strftime($format,$timestamp);
		}
		else $str = strftime($format,$timestamp);
		
		return $str;
	}
}



/*
id
type
contentType
alias
link_attributes
published
parent
isfolder
content
richtext
template
menuindex
searchable
cacheable
deleted
menutitle
donthit
haskeywords
hasmetatags
privateweb
privatemgr
content_dispo
hidemenu
*/
