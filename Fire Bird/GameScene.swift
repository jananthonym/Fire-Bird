//
//  GameScene.swift
//  Fire Bird
//
//  Created by Jan Anthony Miranda on 6/14/15.
//  Copyright (c) 2015 Jan Anthony Miranda. All rights reserved.
//

import SpriteKit
import GameKit
import iAd
import AVFoundation

class GameScene: SKScene, GKGameCenterControllerDelegate, ADBannerViewDelegate {
    var UIiAd: ADBannerView = ADBannerView()
    var hasAd = false
    var showAd = true
    var showAd2 = true
    
    let gameNode = SKSpriteNode()
    
    var maxEruptions = 4
    var spawnInterval:Double = 1.2
    
    var bird = SKSpriteNode(imageNamed: "birdB1.png")
    var started = false
    var pause = false
    var stopped = false
    
    let score = SKLabelNode(fontNamed: "D3 Stonism")
    let highScore = SKLabelNode(fontNamed: "D3 Stonism")
    let endGameLabel = SKSpriteNode(imageNamed: "gameOver.png")
    
    let playBtn  = SKSpriteNode(imageNamed: "playBtn.png")
    let scoreBtn = SKSpriteNode(imageNamed: "scoreBtn.png")
    let pauseBtn = SKSpriteNode(imageNamed: "pauseBtn.png")
    let soundBtn = SKSpriteNode(imageNamed: "soundTrue.png")
    let adBtn = SKSpriteNode(imageNamed: "adBtn.png")
    let restoreBtn = SKSpriteNode(imageNamed: "restoreBtn.png")
    
    let BG = SKSpriteNode(imageNamed: "start.png")
    var bg = SKSpriteNode(imageNamed: "bg.png")
    
    var Score:Int = 0
    
    //volcanoes
    var vol1 = SKSpriteNode(imageNamed: "v1.png")
    var vol2 = SKSpriteNode(imageNamed: "v1.png")
    var vol3 = SKSpriteNode(imageNamed: "v1.png")
    var vol4 = SKSpriteNode(imageNamed: "v1.png")
    var vol5 = SKSpriteNode(imageNamed: "v1.png")
    var vol6 = SKSpriteNode(imageNamed: "v1.png")
    var vol7 = SKSpriteNode(imageNamed: "v1.png")
    var vol8 = SKSpriteNode(imageNamed: "v1.png")
    var vol9 = SKSpriteNode(imageNamed: "v1.png")
    
    var volcanoes = [SKSpriteNode]()
    var eruptions = [Eruption]()
    var erupting = [Int]()
    var coins = [Coin]()
    
    //timer
    var lastUpdate:CFTimeInterval = 0
    var scoreLastUpdate:CFTimeInterval = 0
    var coinTimer:CFTimeInterval = 0
    var spawnIntTimer: CFTimeInterval = 0
    var endGameTimer: CFTimeInterval = 0
    var flapTimer: CFTimeInterval = 0
    
    //bird position
    var birdPos: Int = 5
    var drop = false
    var drop2 = false
    
    var cX: CGFloat = 0.0
    var cY: CGFloat = 0.0
    
    var endScore=0
    
    var faceLeft = true
    
    var lastBird = 0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        gameNode.position = CGPointMake(0, 0)
        //gameNode.s
        self.addChild(gameNode)
        loadAd(true)
        
        self.physicsWorld.gravity = CGVectorMake(0.0, -10)
        
        setupScene()
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedRight:"))
        swipeRight.direction = .Right
        view.addGestureRecognizer(swipeRight)
        
        
        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedLeft:"))
        swipeLeft.direction = .Left
        view.addGestureRecognizer(swipeLeft)
        
        
        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedUp:"))
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)
        
        
        let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedDown:"))
        swipeDown.direction = .Down
        view.addGestureRecognizer(swipeDown)
        
        authenticatePlayer()
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions:AVAudioSessionCategoryOptions.DefaultToSpeaker)
        } catch _ {
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "Pause", name: UIApplicationWillResignActiveNotification, object: nil)
        
    }
    
    func Pause() {
        if started && !pause && !stopped {
            print("pausing")
            pauseBtn.texture = SKTexture(imageNamed: "resumeBtn.png")
            gameNode.paused = true
            pause = true
            speed = 0
        }
    }
    
    func setupScene(){
        
        cX = CGRectGetMidX(self.frame)
        cY = CGRectGetMidY(self.frame)
        
        
        playBtn.position = CGPointMake(self.frame.size.width/4, self.frame.size.height/3)
        self.addChild(playBtn)
        
        scoreBtn.position = CGPointMake(self.frame.size.width/4, self.frame.size.height/7)
        self.addChild(scoreBtn)
        
        adBtn.position = CGPointMake(self.frame.size.width/1.3, self.frame.size.height/6)
        restoreBtn.position = CGPointMake(self.frame.size.width/1.3, self.frame.size.height/11)
        
        let defaults1 = NSUserDefaults.standardUserDefaults()
        let ad = defaults1.objectForKey("ad")
        if let Ad = ad as? Bool {
            if Ad {
                self.addChild(adBtn)
                self.addChild(restoreBtn)
                
            }
        } else {
            self.addChild(adBtn)
            self.addChild(restoreBtn)
            
        }
        
        started = false
        pause = false
        stopped = false
        
        Score = 0
        
        volcanoes.removeAll()
        eruptions.removeAll()
        erupting.removeAll()
        coins.removeAll()
        
        //timer
        lastUpdate = 0
        scoreLastUpdate = 0
        coinTimer = 0
        spawnInterval = 1.2
        flapTimer = 0
        
        //bird position
        birdPos = 5
        drop = false
        drop2 = false
        
        endScore = 0
        
        BG.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        BG.zPosition = -10
        BG.size = self.frame.size
        self.addChild(BG)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if(!started && playBtn.containsPoint(location)){
                //remove start label
                for node in self.children {
                    node.removeFromParent()
                }
                self.addChild(gameNode)
                started = true
                
                scoreBtn.removeFromParent()
                playBtn.removeFromParent()
                
                //spawn volcanoes
                spawnVolcanoes()
                
                //spawn bird
                spawnBird()
                
                //score label
                score.text = "0"
                score.fontSize = self.frame.size.width * (60/320)
                score.position = CGPointMake(self.size.width/2, self.size.height/1.2)
                gameNode.addChild(score)
                score.fontColor = UIColor(red: 0x32/255, green: 0x33/255, blue: 0x33/255, alpha: 1.0)

                highScore.fontColor = UIColor(red: 0x32/255, green: 0x33/255, blue: 0x33/255, alpha: 1.0)
                
                pauseBtn.position = CGPointMake(pauseBtn.size.width/2, self.frame.size.height - pauseBtn.size.height/2)
                pauseBtn.zPosition = 50
                self.addChild(pauseBtn)
                
                bg.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
                bg.size = self.frame.size
                bg.zPosition = -110
                gameNode.addChild(bg)
                
                soundBtn.position = CGPointMake(self.frame.size.width - soundBtn.size.width/2, self.frame.size.height - soundBtn.size.width/2)
                soundBtn.zPosition = 100
                gameNode.addChild(soundBtn)
                let defaults = NSUserDefaults.standardUserDefaults()
                let ssound = defaults.boolForKey("sound")
                if !ssound {
                    soundBtn.texture = SKTexture(imageNamed: "soundFalse.png")
                }

            }else if pauseBtn.containsPoint(location) {
                if(!stopped){
                    if(!pause){
                        pauseBtn.texture = SKTexture(imageNamed: "resumeBtn.png")
                        gameNode.paused = true
                        pause = true
                        speed = 0.0
                    }else{
                        pauseBtn.texture = SKTexture(imageNamed: "pauseBtn.png")
                        gameNode.paused = false
                        pause = false
                        speed = 1.0
                    }
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if stopped && playBtn.containsPoint(location){
                for node in gameNode.children {
                    node.removeFromParent()
                }
                setupScene()
                removeAd(true)
                if !showAd2 {
                    showAd2 = true
                    print("not displaying interstitial")
                    return
                }
                showAd2 = false
                print("displaying interstitial")
                NSNotificationCenter.defaultCenter().postNotificationName("ad", object: self)
                
            }else if scoreBtn.containsPoint(location) && !started {
                showLeader()
                
            }else if adBtn.containsPoint(location) && !started {
                NSNotificationCenter.defaultCenter().postNotificationName("removeAd", object: self)
            }else if restoreBtn.containsPoint(location) && !started {
                NSNotificationCenter.defaultCenter().postNotificationName("restore", object: self)
            } else if soundBtn.containsPoint(location) && started && !stopped {
                let defaults = NSUserDefaults.standardUserDefaults()
                let ssound = defaults.boolForKey("sound")
                if !ssound {
                    soundBtn.texture = SKTexture(imageNamed: "soundTrue.png")
                    defaults.setBool(true, forKey: "sound")
                } else {
                    soundBtn.texture = SKTexture(imageNamed: "soundFalse.png")
                    defaults.setBool(false, forKey: "sound")
                }
            }
            
        }
    }
    
    func spawnBird() {
        bird.removeActionForKey("flap")
        bird.position = CGPointMake(self.size.width/2, self.size.height+30)
        bird.zPosition = 250
        bird.physicsBody?.dynamic = false
        let action = SKAction.moveToY(self.size.height/2, duration: 0.5)
        bird.runAction(action)
        let up = SKAction.moveBy(CGVector(dx: 0, dy: 6), duration: 0.19)
        let down = SKAction.moveBy(CGVector(dx: 0, dy: -6), duration: 0.19)
        let flap = SKAction.sequence([up, down])
        bird.runAction(SKAction.repeatActionForever(flap), withKey: "flap2")
        gameNode.addChild(bird)
        
        var frames = [SKTexture]()
        if lastBird == 0 {
            frames.append(SKTexture(imageNamed: "birdRed1.png"))
            frames.append(SKTexture(imageNamed: "birdRed2.png"))
            frames.append(SKTexture(imageNamed: "birdRed3.png"))
            frames.append(SKTexture(imageNamed: "birdRed2.png"))
            lastBird = 1
        } else {
            frames.append(SKTexture(imageNamed: "birdB1.png"))
            frames.append(SKTexture(imageNamed: "birdB2.png"))
            frames.append(SKTexture(imageNamed: "birdB3.png"))
            frames.append(SKTexture(imageNamed: "birdB2.png"))
            lastBird = 0
        }
        
        bird.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(frames, timePerFrame: 0.13)), withKey: "flap")
        
        if !faceLeft {
            bird.xScale = bird.xScale * -1
            faceLeft = true
        }
    }
    
    func swipedRight(sender:UISwipeGestureRecognizer){
       // println("swiped right")
        if faceLeft && started && !pause && !stopped {
            bird.xScale = bird.xScale * -1
            faceLeft = false
        }
        moveBird(1)
    }
    
    func swipedLeft(sender:UISwipeGestureRecognizer){
       // println("swiped left")
        if !faceLeft && started && !pause && !stopped {
            bird.xScale = bird.xScale * -1
            faceLeft = true
        }
        moveBird(0)
    }
    
    func swipedUp(sender:UISwipeGestureRecognizer){
        //println("swiped up")
        moveBird(2)
    }
    
    func swipedDown(sender:UISwipeGestureRecognizer){
        //println("swiped down")
        moveBird(3)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if(stopped && fabs(score.position.y - self.frame.height/1.95) < 4 && endScore < Score){
            if(currentTime - endGameTimer > 0.01){
                endGameTimer = currentTime
                score.text = String(++endScore)
            }
        }
        if stopped && hasAd && showAd {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(1)
            UIiAd.alpha = 1
            UIView.commitAnimations()
            hasAd = false
        }
        
        if(!stopped && started && !pause){
            
            if !drop2 {
                if isOver(5) {
                    drop2 = true
                    spawnCoin(false)
                }
            }
            
            if(currentTime - spawnIntTimer > 15 && spawnInterval > 0.5){
                spawnIntTimer = currentTime
                spawnInterval -= 0.2
                //println("increasing speed")
            }
            
            if(currentTime - coinTimer > 2){
                for var index=0; index<coins.count; index++ {
                    let coin = coins[index]
                    coin.decTime()
                    if coin.getTime() < 1 {
                        if !coin.isRed() {
                            spawnCoin(false)
                        }
                        coin.getNode().removeFromParent()
                        coins.removeAtIndex(index)
                    }
                }
                
                coinTimer = currentTime
                //spawnCoin()
            }

            if(currentTime - self.lastUpdate > spawnInterval){
                //println("erupting")
                if(eruptions.count < maxEruptions){
                    erupt();
                }
                lastUpdate = currentTime
            }
            
            var step: Int = 0
            for var index = 0; index<eruptions.count; index++ {
                let erupts = eruptions[index]
                
                
                if(currentTime - erupts.getLast() > 1){
                    //println("size " + String(eruptions.count))
                    erupts.setLast(currentTime)
                    erupts.incStep()
                    step = erupts.getStep()
                    
                    if(step<3){
                        erupts.getNode().texture=SKTexture(imageNamed: "v"+String(step + 1)+".png")
                        let defaults1 = NSUserDefaults.standardUserDefaults()
                        let ssound = defaults1.boolForKey("sound")
                        if ssound {
                            self.runAction(SKAction .playSoundFileNamed("vol"+String(step)+".wav", waitForCompletion: false))
                        }
                        if(step == 1){
                            let shake = SKAction.shake(erupts.getNode().position, duration: 1, amplitudeX: Int(self.frame.size.height *  6/480), amplitudeY: Int(self.frame.size.height * 5/480))
                            erupts.getNode().runAction(shake)
                        }
                        
                    }else{
                        erupts.getNode().texture=SKTexture(imageNamed: "v1.png")
                        eruptions.removeAtIndex(index)
                    }
                }
                step = erupts.getStep()
                if(step==2 && isOver(erupts.id)){
                    //end game
                    //bird.removeActionForKey("flap")
                    bird.removeActionForKey("flap2")
                    endGame()
                }
            }
            
            for var index=0; index<coins.count; index++ {
                let coin = coins[index]
                //if(bird.frame.intersects(coin.getNode().frame) && drop2){
                if(isOverCoin(coin.getPos()) && drop2){
                    coins.removeAtIndex(index)
                    if(coin.isRed()){
                        Score+=2
                    } else {
                        Score+=1
                        spawnCoin(false)
                    }
                    score.text = String(Score)
                    coin.getNode().runAction(SKAction.moveByX(0, y: coin.getNode().size.height/3, duration: 0.3))
                    coin.getNode().runAction(SKAction.sequence([SKAction.waitForDuration(0.1), SKAction.fadeOutWithDuration(0.3), SKAction.removeFromParent()]))
                    let defaults1 = NSUserDefaults.standardUserDefaults()
                    let ssound = defaults1.boolForKey("sound")
                    if ssound {
                        self.runAction(SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false))
                    }
                }
            }
        }else if(!pause){
            for volcano in volcanoes {
                volcano.texture = SKTexture(imageNamed: "v3.png")
            }
        }
        
    }
    
    func isOver(posi: Int) -> Bool {
        let pos = getPos(posi)
        if(fabs(pos.x - bird.position.x) < 1 && fabs(pos.y - bird.position.y) < 1){
            return true
        }
        return false
    }
    
    func isOverCoin(posi: Int) -> Bool {
        let pos = getPos(posi)
        if(fabs(pos.x - bird.position.x) < 10 && fabs(pos.y - bird.position.y) < 10){
            return true
        }
        return false
    }
    
    func isErupting(id:Int) -> Int{
        for elem in eruptions {
            if elem.getID() == id {
                return elem.getStep()
            }
        }
        return 0
    }
    
    func erupt(){
        if(started && !pause){
            var A: Eruption
            var index: Int
            var mid: Int = -1
            if(!drop){
                mid = 4
                drop = true
            }
            repeat{
                let half = Int(arc4random_uniform(2))
                if(half == 0){
                    index = Int(arc4random_uniform(9)) //0-8
                }else{
                    index = birdPos-1
                }
            }while(isErupting(index+1) != 0 || index == mid)
            if(mid == 5) {
                mid = -1
            }
            print(index+1)
            A=Eruption(node: volcanoes[index], ID: index+1)
            eruptions.append(A)
        }
    }
    
    func canMove(pos: Int) -> Bool {
        switch pos {
        case 0:
            if(birdPos == 1 || birdPos == 4 || birdPos == 7){
                return false
            }
        case 1:
            if(birdPos == 3 || birdPos == 6 || birdPos == 9){
                return false
            }
        case 2:
            if(birdPos == 1 || birdPos == 2 || birdPos == 3){
                return false
            }
        case 3:
            if(birdPos == 7 || birdPos == 8 || birdPos == 9){
                return false
            }
        default:
            return false
        }
        return true
    }
    
    func moveBird(dir: Int){
        let speed = 0.2
        var action: SKAction
        
        if(canMove(dir) && drop2 && started && !pause && !stopped){
            if(dir==0){//left
                //println("left")
                birdPos--
            }else if(dir==1){//right
                //println("right")
                birdPos++
            }else if(dir==2){//up
                //println("up")
                birdPos-=3
            }else if(dir==3){//down
                //println("down")
                birdPos+=3
            }
            let defaults1 = NSUserDefaults.standardUserDefaults()
            let ssound = defaults1.boolForKey("sound")
            if ssound {
                self.runAction(SKAction.playSoundFileNamed("move.wav", waitForCompletion: false))
            }
            action = SKAction.moveTo(getPos(birdPos), duration: speed)
            bird.runAction(action)
        }
        //println("bird pos: " + String(birdPos))
    }
    
    func endGame(){
        //loadAd(true)
        
        pauseBtn.removeFromParent()
        soundBtn.removeFromParent()
        let defaults1 = NSUserDefaults.standardUserDefaults()
        let ssound = defaults1.boolForKey("sound")
        if ssound {
            self.runAction(SKAction.playSoundFileNamed("endgame.wav", waitForCompletion: false))
        }
        
        bird.physicsBody = SKPhysicsBody(rectangleOfSize: bird.size)
        bird.physicsBody?.dynamic=true
        if self.frame.size.width < 768 {
            bird.physicsBody?.applyImpulse(CGVectorMake(0, 140))
        } else {
            bird.physicsBody?.applyImpulse(CGVectorMake(0, 700))
        }
        stopped = true
        
        endGameLabel.texture = SKTexture(imageNamed: "gameOver.png")
        
        let defaults = NSUserDefaults.standardUserDefaults()
        var best = defaults.integerForKey("High_Score")
        if best < Score {
            //New High Score!
            print("New High Score")
            defaults.setInteger(Score, forKey: "High_Score")
            best = Score
            endGameLabel.texture = SKTexture(imageNamed: "highScore.png")
        }
        endGameLabel.size = endGameLabel.texture!.size()
        
        
        playBtn.position = CGPointMake(self.frame.size.width/2, -playBtn.size.height/2)
        playBtn.zPosition = 200
        let upAction = SKAction.moveToY(self.frame.size.height/5, duration: 0.3)
        playBtn.runAction(SKAction.sequence([SKAction.waitForDuration(0.5), upAction]))
        gameNode.addChild(playBtn)
        
        let end = SKSpriteNode(imageNamed: "endBox.png")
        end.position = CGPointMake(self.frame.width/2, self.frame.height + self.frame.height/2)
        end.zPosition = 200
        var action = SKAction.moveToY(self.frame.height/2, duration: 0.5)
        end.runAction(action)
        gameNode.addChild(end)
        
        if Score >= 15 {
            var medal = SKSpriteNode(imageNamed: "medalBronze.png")
            if Score >= 55 {
                medal = SKSpriteNode(imageNamed: "medalSilver.png")
            } else if Score >= 100 {
                medal = SKSpriteNode(imageNamed: "medalGold.png")
            }
            medal.size = medal.texture!.size()
            medal.position = CGPointMake(self.frame.width/3, self.frame.height/2)
            medal.zPosition = 200
            medal.alpha = 0
            action = SKAction.fadeInWithDuration(0.5)
            medal.runAction(SKAction.sequence([SKAction.waitForDuration(1), action]))
            gameNode.addChild(medal)
        }
        
        score.text = "0"
        score.fontSize = self.frame.size.width * (35/320)
        score.position = CGPointMake(self.frame.width/1.5, self.frame.height + self.frame.height/1.95)
        score.zPosition = 201
        let action2 = SKAction.moveToY(self.frame.height/1.95, duration: 0.5)
        score.runAction(action2)
        
        highScore.text = String(best)
        highScore.fontSize = self.frame.size.width * (35/320)
        highScore.position = CGPointMake(self.frame.width/1.5, self.frame.height + self.frame.height/2.6)
        highScore.zPosition = 201
        var action3 = SKAction.moveToY(self.frame.height/2.6, duration: 0.5)
        if self.frame.size.width == 375 || self.frame.size.width == 414 {
            action3 = SKAction.moveToY(self.frame.height/2.4, duration: 0.5)
        }
        highScore.runAction(action3)
        gameNode.addChild(highScore)
        
        endGameLabel.position = CGPointMake(self.frame.width/2, self.frame.height + self.frame.height/1.2)
        endGameLabel.zPosition = 200
        let action4 = SKAction.moveToY(self.frame.height/1.2, duration: 0.5)
        endGameLabel.runAction(action4)
        gameNode.addChild(endGameLabel)
        
        saveHighScore()
    }
    
    
    func isCoin(id:Int) -> Bool{
        for elem in coins {
            if elem.getPos() == id {
                return true
            }
        }
        return false
    }
    
    func spawnCoin(Red: Bool = false){
        
        let c = SKSpriteNode(imageNamed: "coinYellow.png")
        var index: Int
        
        repeat{
            index = Int(arc4random_uniform(9))+1
        }while(birdPos == index || isCoin(index))
        
        let coin = Coin(Node: c, Pos: index)
        c.alpha = 0
        
        if !Red {
            coins.append(coin)
            c.position = getPos(index)
            c.zPosition = 10
            gameNode.addChild(c)
            c.runAction(SKAction.fadeInWithDuration(0.2))
            
            let red = Int(arc4random_uniform(6))
            if red == 0 {
                spawnCoin(true)
            }
        } else {
            coin.getNode().texture = SKTexture(imageNamed: "coinRed.png")
            coin.setRed()
            
            coins.append(coin)
            c.position = getPos(index)
            c.zPosition = 10
            gameNode.addChild(c)
            c.runAction(SKAction.fadeInWithDuration(0.2))
            
        }
        
        
    }
    
    func spawnVolcanoes(){
        volcanoes.insert(vol1, atIndex: 0)
        volcanoes.insert(vol2, atIndex: 1)
        volcanoes.insert(vol3, atIndex: 2)
        volcanoes.insert(vol4, atIndex: 3)
        volcanoes.insert(vol5, atIndex: 4)
        volcanoes.insert(vol6, atIndex: 5)
        volcanoes.insert(vol7, atIndex: 6)
        volcanoes.insert(vol8, atIndex: 7)
        volcanoes.insert(vol9, atIndex: 8)
        
        for var index = 0; index < volcanoes.count; index++ {
            let volcano = volcanoes[index]
            volcano.zPosition = 0
            volcano.texture = SKTexture(imageNamed: "v1.png")
            volcano.position = getPos(index+1)
            gameNode.addChild(volcano)
        }
    }
    
    func getPos(pos: Int) -> CGPoint {
        
        let delta = vol1.size.width
        let centerX = round(cX*10)/10
        let centerY = round(cY*10)/10
        
        switch pos{
        case 1:
            return CGPoint(x: centerX - delta, y: centerY+delta)
        case 2:
            return CGPoint(x: centerX, y: centerY+delta)
        case 3:
            return CGPoint(x: centerX+delta, y: centerY+delta)
        case 4:
            return CGPoint(x: centerX-delta, y: centerY)
        case 5:
            return CGPoint(x: centerX, y: centerY)
        case 6:
            return CGPoint(x: centerX+delta, y: centerY)
        case 7:
            return CGPoint(x: centerX-delta, y: centerY-delta)
        case 8:
            return CGPoint(x: centerX, y: centerY-delta)
        case 9:
            return CGPoint(x: centerX+delta, y: centerY-delta)
        default:
            return CGPoint(x: centerX-delta, y: centerY+delta)
        }
    }
    
    // Game Center
    func saveHighScore() {
        if(GKLocalPlayer.localPlayer().authenticated) {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "fire_bird")
            
            let defaults = NSUserDefaults.standardUserDefaults()
            let best = defaults.integerForKey("High_Score")
            scoreReporter.value = Int64(best)
            
            print("Submitting: "+String(scoreReporter.value))
            
            let scoreArray: [GKScore] = [scoreReporter]
            GKScore.reportScores(scoreArray, withCompletionHandler: {(error : NSError?) -> Void in
                if error != nil {
                    print("error")
                    print(error!.localizedDescription)
                }else{
                    print("Submitted Score")
                }
            })
        }else{
            print("Not Logged In")
        }
    }
    
    func showLeader() {
        if(GKLocalPlayer.localPlayer().authenticated) {
            let vc = self.view?.window?.rootViewController
            let gc = GKGameCenterViewController()
            gc.gameCenterDelegate = self
            gc.viewState = GKGameCenterViewControllerState.Leaderboards
            gc.leaderboardIdentifier = "fire_bird"
            vc?.presentViewController(gc, animated: true, completion: nil)
        }
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController){
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func authenticatePlayer() {
        //log in player to game center
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if viewController != nil {
                let vc = self.view?.window?.rootViewController
                vc?.presentViewController(viewController!, animated: true, completion: nil)
            }else{
                print("Authenticated: " + String(stringInterpolationSegment: GKLocalPlayer.localPlayer().authenticated))
            }
        }
    }
    //iAd
    func loadAd(animated: Bool) {
        let defaults1 = NSUserDefaults.standardUserDefaults()
        let ad = defaults1.objectForKey("ad")
        if let Ad = ad as? Bool {
            if !Ad {
                return
            }
        }
        if !hasAd {
            print("loading banner ad")
            let S = UIScreen.mainScreen().bounds
            UIiAd.delegate = self
            UIiAd.frame = CGRectMake(0, S.height - UIiAd.frame.height, S.width, 0)
            //UIiAd.center = CGPoint(x: S.width/2, y: S.height/2 - UIiAd.frame.height)
            UIiAd.alpha = 0
            //UIiAd.con
            self.view?.addSubview(UIiAd)
        }
    }
    
    // 3
    func removeAd(animated: Bool) {
        UIiAd.delegate = nil
        UIiAd.removeFromSuperview()
        hasAd = false
        loadAd(true)
    }
    
    // 4
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        hasAd = true
        
        print("Ad loaded")
    }
    
    // 5
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        print(error)
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0)
        UIiAd.alpha = 0
        UIView.commitAnimations()
        hasAd = false
        loadAd(true)
    }
}
