EarthApp = function () 
{
	Sim.App.call(this);
}

//constructor 
EarthApp.prototype = new Sim.App();

//adding luggage to EarthApp
EarthApp.prototype.init = function (param) 
{
	Sim.App.prototype.init.call(this, param);

	var earth = new Earth();
	earth.init();
	this.addObject(earth);

	var sun = new Sun();
	sun.init();
	this.addObject(sun);

}

//constructor
Earth = function () 
{
	Sim.Object.call(this);
}

//prototype of earth will become a new prototype
Earth.prototype = new Sim.Object();

Earth.prototype.init = function () 
{
	var earthGroup = new THREE.Object3D();

	this.setObject3D(earthGroup);

	this.createGlobe();
	this.createClouds();
	this.createMoon();
}

Earth.prototype.createGlobe = function () 
{
	var surfaceMap = THREE.ImageUtils.loadTexture("/images/earth_surface_2048.jpg");
	var normalMap = THREE.ImageUtils.loadTexture("/images/earth_normal_2048.jpg");
	var specularMap = THREE.ImageUtils.loadTexture("/images/earth_specular_2048.jpg");

	var shaderMaterial = new THREE.MeshPhongMaterial({
		map: surfaceMap,
		normalMap: normalMap,
		specularMap: specularMap
	});

	var globeGeometry = new THREE.SphereGeometry(1, 32, 32);

	var globeMesh = new THREE.Mesh( globeGeometry, shaderMaterial );

	globeMesh.rotation.z = Earth.TILT;

	this.object3D.add(globeMesh);

	this.globeMesh = globeMesh;
}

Earth.prototype.createClouds = function () {
	var cloudsMap = new THREE.ImageUtils.loadTexture("/images/earth_clouds_1024.png")
	var cloudsMaterial = new THREE.MeshLambertMaterial({ color: 0xffffff, map: cloudsMap, transparent: true });
	var cloudsGeometry = new THREE.SphereGeometry(Earth.CLOUDS_SCALE, 32, 32 );
	var cloudsMesh = new THREE.Mesh( cloudsGeometry, cloudsMaterial );
	cloudsMesh.rotation.z = Earth.TILT;

	this.object3D.add( cloudsMesh );

	this.cloudsMesh = cloudsMesh;
}

Earth.prototype.createMoon = function () 
{
	var moon = new Moon();
	moon.init();
	this.addChild(moon);
}

Earth.prototype.update = function () 
{
	this.globeMesh.rotation.y += Earth.ROTATION_Y;
	this.cloudsMesh.rotation.y += Earth.CLOUDS_ROTATION_Y;
	Sim.Object.prototype.update.call(this);
}

Earth.ROTATION_Y = 0.0025;
Earth.TILT = 0.41;
Earth.CLOUDS_SCALE = 1.005;
Earth.CLOUDS_ROTATION_Y = Earth.ROTATION_Y * 1.3;
Earth.RADIUS = 6371;

Sun = function () {
	Sim.Object.call(this);
}

Sun.prototype = new Sim.Object();

Sun.prototype.init = function () {
	var light = new THREE.PointLight( 0xffffff, 2, 100 );
	light.position.set(-10,0,20);
	this.setObject3D(light);
}

Moon = function () {
	Sim.Object.call(this);
}

Moon.prototype = new Sim.Object();

Moon.prototype.init = function () 
{
	var MOONMAP = "/images/moon_1024.jpg";

	var geometry = new THREE.SphereGeometry(Moon.SIZE_IN_EARTHS, 32, 32 );
	var texture = THREE.ImageUtils.loadTexture(MOONMAP);
	var material = new THREE.MeshPhongMaterial( { map: texture, ambient: 0x888888 } );
	var mesh = new THREE.Mesh( geometry, material );

	var distance = Moon.DISTANCE_FROM_EARTH / Earth.RADIUS;
	mesh.position.set( Math.sqrt(distance / 2), 0, -Math.sqrt(distance / 2) );
	mesh.rotation.y = Math.PI;

	var moonGroup = new THREE.Object3D();
	moonGroup.add(mesh);

	moonGroup.rotation.x = Moon.INCLINATION;

	this.setObject3D(moonGroup);

	this.moonMesh = mesh;
}

Moon.prototype.update = function () 
{
	this.object3D.rotation.y += ( Earth.ROTATION_Y / Moon.PERIOD );
	Sim.Object.prototype.update.call(this);
}

Moon.DISTANCE_FROM_EARTH = 356400;
Moon.PERIOD = 28;
Moon.EXAGGERATE_FACTOR = 1.2;
Moon.INCLINATION = 0.089;
Moon.SIZE_IN_EARTHS = 1 / 3.7 * Moon.EXAGGERATE_FACTOR;



//NOTES:
//start local server access go to terminal, change directory to "classTestServer" and enter "shotgun config.ru"
//class starts capitaalized and then camel-case like "SphereGeometry"
//function starts lower case and then camel-case
//static function?
//constants are ALL_CAPS like "ROTATION_Y"
//"Sim" is an upper class that sits on everything.  It breaks out into "App" & "Object"
//"App" has Scene/Camera/Renderer/Canvas/addObject3D/getCamera/setCamera
//example: function addObject( object ) { scene.add( object ); }
//"Object" has Earth/this.object/setObject3D
//example:  Sim.App.call(this);
//"this" is my instance - inheritance - adding luggage
//"call" is to add stuff
//"phong" lighting - each vector has a "normal" vector or perpendicular vector
//":" designate a "key: value" as in "map: surfaceMap"
//"this.globeMesh = globeMesh;"" adds luggage to the Earth object - 
//"Earth" is an object - an object contains THREE.js and other objects
//We set earth as a abstracted container "earthgroup" to which we add "globe" & "clouds" (both have geometry & materials)
//hierarchy:  Earth Object > Earth Group > Earth & Clouds Luggage 
//"this.object3D.add(globeMesh);" goes to the object heirarchy (list) of THREE.js
//"this.globeMesh = globeMesh;" goes to the instance of Earth






