<h1>Party System for FiveM Servers</h1>

<h2>What's it for?</h2>
<p>This mod is designed to allow players to make parties and then do things as groups, it doesn't really do anything on it's own</p>

<h2>So how do I use it as a Mod author?</h2>
<p>When setup and configured the mod has some <b>Server</b> exports which can be called by other mods for use</p>

<h3>HostingParty()</h3>
Returns boolean based on whether the player source is hosting a party

```
exports['Party-System']:HostingParty(source)
```

<h3>GetPartySources()</h3>
Returns a list of sources in a players party (including the host)

```
exports['Party-System']:GetPartySources(source)
```

With just that you can then trigger events for all players in the party!

<h2>Installation</h2>
The Mod is in early stages for now, so these instructions are pretty basic and require more manual work.
<ol>
  <li>Download the latest stable version.</li>
  <li>Place in the servers tx admin/resources folder.</li>
  <li>Edit your server config to load the mod.</li>
</ol>

<h2>How do I use it in game?</h2>
<ol>
  <li>Open and close the UI with the "o" key.</li>
  <li>Invite players in server list on the left, they'll recieve an invite.</li>
  <li>The other player opens the UI on their side and and accept or reject. (It will also time-out with a configurable value)</li>
  <li>If they accept they join your party!</li>
  <li>The party owner can also remove party members.</li>
</ol>

Note: the open key can be rebound in FiveM but not the close, I plan to fix that at some point.

<h2>Planned Features</h2>
<ul>
  <li>Notifications when players leaver or ar kicked</li>
  <li>Ability to leave party (yeah I know)</li>
  <li>Styling pass.</li>
  <li>Muting invites system.</li></ul>
