![](https://foxdeploy.files.wordpress.com/2016/09/dsc-designer-3.png)

# DSC-Designer #

----------

A project to build a Group Policy like frontend for Desired State Configuration

# What is it?

Have you ever wished DSC were a little more 'wizard-like', maybe resembling something like other Microsoft tools?  Then you'll like this project!

![](https://foxdeploy.files.wordpress.com/2016/09/complete-ui.png)


# How do I use it?

Download the .ps1 file in this project and run the script like so:

.\Start-DSCDesigner.ps1

# What works?  

Currently, we are able to scrape all available DSC Resources installed on your machine, parse out the required syntax for each, and then, with a click of a button, export a valid DSC Configuration for application on systems in your environment.  

# How can I contribute?

Contributions are simple.  First, don't sell it!  Secondly, simply fork the project, make your own commit and then send me a pull-request.  That's it!

Is it broke? *Open an issue, please :smile:* 

# What's planned?

This project has been a work-in-progress since the MVP Summit last year, when I tried to get MS to make this UI, and they told me to do it on my own!  So this is version 1.0, the mostly-functional-get-it-out-the-door release.  Here's the planned features for somewhere down the road.
<table>
<tbody>
<tr>
<th>Version</th>
<th>Feature</th>
<th>Completed</th>
</tr>
<tr>
<td>1.0</td>
<td>Released!</td>
<td>✔️</td>
</tr>
<tr>
<td>1.1</td>
<td>Ability to enact the configuration on your machine</td>
<td></td>
</tr>
<tr>
<td>1.2</td>
<td>Button to jump to local dsc resource folder</td>
<td></td>
</tr>
<tr>
<td>2.0</td>
<td>Display DSC Configuration as a form</td>
<td></td>
</tr>
<tr>
<td>2.?</td>
<td>render absent/present as radio button</td>
<td></td>
</tr>
<tr>
<td>?</td>
<td>render multi-choice as a combobox</td>
<td></td>
</tr>
<tr>
<td>?</td>
<td>render other options as checkbox</td>
<td></td>
</tr>
<tr>
<td>?</td>
<td>render string as a textbox</td>
<td></td>
</tr>
<tr>
<td>?</td>
<td>Display DSC Configuration as a form</td>
<td></td>
</tr>
<tr>
<td>??</td>
<td>Track configuration Drift?</td>
<td></td>
</tr>
</tbody>
</table>

# How was it made?