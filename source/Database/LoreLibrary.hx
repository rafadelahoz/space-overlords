package;

import flixel.FlxG;

class LoreLibrary
{
    static var LoreOther : Int = -1;
    static var LoreArtifact : Int = 1;
    static var LoreComplaint : Int = 2;
    static var LoreMutants : Int = 3;

    static var LoreSequence : Array<Int>;

    static var MainLore : Array<String>;

    static var ArtifactIntro : Array<String>;
    static var ArtifactLore : Array<String>;
    static var Videogames : Array<String>;
    static var BookTitles : Array<String>;
    static var FoodBoxes : Array<String>;

    static var ComplaintsIntro : Array<String>;
    static var ComplaintsLore : Array<String>;

    static var MutantsIntro : Array<String>;
    static var MutantsLore : Array<String>;
    static var MutantsEnd : Array<String>;

    public static function Init()
    {
        { // Main Lore
            MainLore = [];

            MainLore.push("I'm always amazed by the amount of pollution present on this planet. Can you believe it? Our records show that it was some of the green-est planets on this arm of the galaxy.");
            MainLore.push("We have lost a full cleaning machinery set today while operating near the dry section of the ocean. A huge wave came out of nowhere, destroying all the equipment. We still don't know what may have caused it.");
            MainLore.push("How come there are so many mutants in this planet? We must have processed thousands of them! Normally eco-mutants either lack the required population count to evolve, or reach species level by the time we arrive. In that case we can't clean the planet, since the corrupted ecosystem becomes their home. But this planet mutants are just... awful?");
            MainLore.push("Cleaning planets is a tiresome labour. I have to deal with all kind of situations, make sure the quotas are met, handle the slacking of the ship crew, and select the catering provider every work period. It's really exhausting!");
            MainLore.push("Today the ecology team was showing me the remnants of what they thought was one of the biggest forest of the planet, when suddenly pink water began to fall from the sky. It dissolved part of the ecology team and some slaves. What did the species of this planet do to the ecosystem?");
            MainLore.push("Look, I have to be honest. I would love to do what you slaves do. You get to have all the fun with the trash and the pollution and the mutants. I, on the other hand, have to sit here all day, making sure work gets done, planets get cleaned, making the galaxy a better place. I envy you!");
            MainLore.push("I hope we can finish the cleansing soon, so we can start with the re-naturing phase. I love the re-naturing phase. Looking at those young plants growing from moist terrain, bringing back life to derelict lands makes me feel that we are doing something really special.");
            MainLore.push("The most advanced life forms of this planet apparently left before the environment collapsed. Being water based, they must have discovered pretty soon that pollution was reaching critical levels.");
            MainLore.push("We have discovered that the culprit for the extreme levels of ecological corruption of this planet are a species called HOMINS. These HOMINS were able to undo billions of years of impressive natural development in just a handful of millenia.");
            MainLore.push("Have you noticed those coloured capsule things in the processing plant? The science team says there are countless amounts of those in HOMINS settlements. They seemed to use them like health tokens, as well as for ludic purposes. They can't tell why there are so many of those left, though.");
            MainLore.push("Our Xeno-archeology team still can't figure out why the water-based advanced species didn't warn those HOMINS about the damage they were making to the environment. Maybe they had already decided to leave?");
            MainLore.push("I'm really sad today. The science team has written a new report on HOMINS. It would seem that, after they destroyed the whole surface nature ecosystem, they started digging tunnels in order to pollute the planet from the inside. They actually managed to do it. That's why we also have to clean the underground.");
            MainLore.push("The Xeno-biology team's latest reports on HOMINS are quite interesting. They required a specific compound, called SWEET WATER, for survival. But they were quite focused on making it disappear from their planet! They eventually managed to vanish it.");
            MainLore.push("It seems that the last centuries of existence of the HOMINS were really hard for them. There was almost no SWEET WATER left for them to supply from, and they started to artificially adapt their nutrition systems to process other sources of nourishment. It must have been painful. And disgusting.");
            MainLore.push("I have been thinking about the whole slavery thing. It would seem that forcing other species to work for you is not seen with keen eyes by some less developed civilizations. You don't seem to mind to be forced to work here, do you?");
            MainLore.push("The xeno-historian team just filled a new report about HOMINS. It seems that they were pretty opposed to slavery other kinds of forced labour. Given that they were the ones that destroyed their home planet, destroying thousands of species in the process... I'm sure we can agree on slavery being right.");
            MainLore.push("We found the cause of the sudden huge waves. There are billions of mutants dwelling in the deepest parts of the ocean. It is quite a sight. The waves happen when they all move at the same time.");
            MainLore.push("We discovered something new about HOMINS today. They had this tribal custom of adopting wild beasts as their companions. They called them \"PETS\" and they had to look after them. Maybe we could get you a PETS?");
            MainLore.push("You know this weird material that is scattered around the whole planet? The science team says it's not a natural resource! Turns out HOMINS produced it! They used it for everything. It was named something like PLASTIX. They must have really liked it, because they didn't develop a way to dispose of it. It's literally everywhere!");
            MainLore.push("The underwater team has located an abandoned HOMINS settlement in the bottom of the ocean. It was really big, and full of things HOMINS seemed to consider valuable. It would seem that the wealthiest of them lived there for centuries.");
            MainLore.push("The xeno-historian team found some data about the late HOMINS period. After life conditions in the planet became unbearable, they split into smaller communities, settling in wherever natural resources were still present. They fought each other for resources until one small community remained. It was the one at the bottom of the ocean.");
            MainLore.push("The xeno-archeology team has finally managed to translate the communication artifacts we found in the last underwater HOMINS settlement.#It seems that the remnant of the HOMINS species ultimately decided to vanish themselves from existence. They left a myriad of memorial documentary items in an attempt to preserve their history, from the dawn of their species to the telling of how they failed to preserve their planet, which they happen to refer to as \"EARTH\".#A fascinating species, they were.#...#Of course, we have dutifully destroyed every single piece of information they left.#We will continue cleaning this EARTH, but it will take many many more work cycles. Any other HOMINS artifact, remnant, or trace we may find will also be destroyed.#HOMINS must have been the single worst species ever to happen in this infinite universe. I'm glad they are gone.#Using a HOMINS expression:\nFUCK YOU, HOMINS.\nFUCK YOU VERY VERY MUCH.");
        }

        { // Artifacts Lore
            ArtifactIntro = [];
            ArtifactIntro.push("We found a new HOMINS artifact today.");
            ArtifactIntro.push("The science team found a new HOMINS artifact today.");

            ArtifactLore = [];
            ArtifactLore.push("It was a really small and flat screen with small buttons on the side. The science team member that was manipulating it dropped it, and the thing broke very quickly. It was really cute, though, I wish I had one...");
            ArtifactLore.push("It was one of those bunch of pieces of paper with things written on them. This one read something like \"#{book}\"");
            ArtifactLore.push("The science team says it is a HOMINS skull. It's pretty weird, they must have been a wild bunch.");
            ArtifactLore.push("It is a small plastic box with colorful things drawn on it. It said \"#{game}\". Science team says it was part of the HOMINS culture, every HOMINS settlement may have had one.");
            ArtifactLore.push("It is a small piece of paper. The research team has discovered that it was called a \"receipt\". HOMINS exchanged it for services. This one is for some kind of pet cleaning machine.");
            ArtifactLore.push("It was a colorful box full of some kind of nutritive substance. Our analysis show that it was artificial matter. Probably HOMINS ran out of food sources at some point, and started producing this thing. The box said \"#{food}\"");

            Videogames = [];
            Videogames.push("CATBOMB 64");
            Videogames.push("FIRE FIGHTER FIGHTER");
            Videogames.push("Yellow Bun Quest");
            Videogames.push("Dreamscapes");
            Videogames.push("Grand Hotel Adventure");
            Videogames.push("Axe Throwing Arcade");
            Videogames.push("Radox Boquet");
            Videogames.push("The Ripges Effect - Adventures at Calx");

            BookTitles = [];
            BookTitles.push("50 ways to drink urine");
            BookTitles.push("How to hide your water reserves from your family");
            BookTitles.push("Water Wars - The darkest period in mankind history");
            BookTitles.push("Are sea urchins more intelligent than us?");
            BookTitles.push("The failure of space travel. What went wrong?");
            BookTitles.push("15 reasons there are no cows left");
            BookTitles.push("Help! My kid is a mutant! An illustrated guide for confused parents");
            BookTitles.push("How to keep your vegetables from turning into red mutants.");

            FoodBoxes = [];
            FoodBoxes.push("BUG-FLAVOURED");
            FoodBoxes.push("NOW WITH LESS URINE!");
            FoodBoxes.push("TASTES LIKE GRANDMA");
            FoodBoxes.push("MDMA-FLAVOURED");
            FoodBoxes.push("HAPPY PILL INCLUDED");
            FoodBoxes.push("DO NOT INGEST IF YOU HAVE MUTATIONS");
            FoodBoxes.push("Eat only in case of emergency");
            FoodBoxes.push("(Disclaimer: Not actually edible)");
        }

        { // Complaints Lore
            ComplaintsIntro = [];
            ComplaintsIntro.push("Look. I'm three galaxy cores away from home. I'm responsible for cleaning this absolutely polluted shoddy excuse of a planet. With the current production rates we won't be finished until the next millenia...");
            ComplaintsIntro.push("Another trash processor imploded today. I am always complaining to upper management about the equipment they send, but they never listen.");
            ComplaintsIntro.push("I got a neuro-call from home today. I miss my assigned family so much.");

            ComplaintsLore = [];
            ComplaintsLore.push("And, of course, the slaves I get are always the ugliest ones. Is it too much to ask for cute slaves? Oh well.");
            ComplaintsLore.push("And you do think you have problems?");
            ComplaintsLore.push("But at least you reached your quota.");
            ComplaintsLore.push("Why does everything need to be so hard?");
            ComplaintsLore.push("Everything started going downhill since I was promoted to Overlord.");
        }

        { // Mutants Lore
            MutantsIntro = [];
            MutantsIntro.push("Today I went out to see the mutants for myself. There were lots of them loitering around the trash.");

            MutantsLore = [];
            MutantsLore.push("One of them was mesmerized by its own reflection on a chemical puddle.");
            MutantsLore.push("There was one that looked a lot like yourself.");
            MutantsLore.push("A member of xenobiology team tried to touch one of them, and the mutant ate its tactile appendix.");
            MutantsLore.push("One of them was making this rhythmic sounds, as if it were singing.");
            MutantsLore.push("One of the smaller ones was making this wiggly dance in the chemical mud.");
            MutantsLore.push("A fight broke between a big cluster of them. The biggest one won, and started coming towards us.");
            MutantsLore.push("I tried talking to one of them. It just gurgled at me.");

            MutantsEnd = [];
            MutantsEnd.push("We finally got him with the pulse rifle.");
            MutantsEnd.push("They ran away before we could catch one.");
            MutantsEnd.push("We really have to speed up processing those things.");
            MutantsEnd.push("I really laughed at that!");
            MutantsEnd.push("There is something really eerie about those things...");
            MutantsEnd.push("They are the cutest thing ever.");

        }

        { // Sequence setup
            LoreSequence = [];
            for (i in 0...MainLore.length)
            {
                LoreSequence.push(i);
            }

            var counter : Int = 0;
            var delta : Int = 3;
            while ((counter + delta) < LoreSequence.length)
            {
                counter += delta;
                LoreSequence.insert(counter, LoreOther);
                counter += 1;

                if (delta == 3)
                    delta = 2;
                else
                    delta = 3;
            }
        }
    }

    public static function getLore() : String
    {
        var index : Int = ProgressData.data.slave_count - 1;

        var nextToken : Int = -1;
        if (index < LoreSequence.length)
            nextToken = LoreSequence[index];
        else
            nextToken = LoreOther;

        if (nextToken >= 0)
        {
            return MainLore[nextToken];
        }
        else
        {
            return getOtherLore(index);
        }

        return null;
    }

    static function getOtherLore(index : Int) : String
    {
        var lastMainLoreEntry : Int = LoreSequence[index-1];

        var types : Array<Int> = [LoreComplaint, LoreMutants];
        // Check if info about homins is allowed
        if (lastMainLoreEntry >= 8)
            types.push(LoreArtifact);

        var type : Int = FlxG.random.getObject(types);
        switch (type)
        {
            case LoreLibrary.LoreArtifact:
                return getArtifactLore();
            case LoreLibrary.LoreComplaint:
                return getComplaintLore();
            case LoreLibrary.LoreMutants:
                return getMutantsLore();
            default:
                return "";
        }
    }

    static function getArtifactLore() : String
    {
        var intro : String = FlxG.random.getObject(ArtifactIntro);
        var body : String = FlxG.random.getObject(ArtifactLore);
        if (body.indexOf("#{book}") > -1)
        {
            body = StringTools.replace(body, "#{book}", FlxG.random.getObject(BookTitles));
        }
        else if (body.indexOf("#{game}") > -1)
        {
            body = StringTools.replace(body, "#{game}", FlxG.random.getObject(Videogames));
        }
        else if (body.indexOf("#{food}") > -1)
        {
            body = StringTools.replace(body, "#{food}", FlxG.random.getObject(FoodBoxes));
        }

        return intro + "#" + body;
    }

    static function getComplaintLore() : String
    {
        var intro : String = FlxG.random.getObject(ComplaintsIntro);
        var body : String = FlxG.random.getObject(ComplaintsLore);

        return intro + "#" + body;
    }

    static function getMutantsLore() : String
    {
        var intro : String = FlxG.random.getObject(MutantsIntro);
        var body : String = FlxG.random.getObject(MutantsLore);
        var end : String = FlxG.random.getObject(MutantsEnd);

        return intro + "#" + body + "#" + end;
    }

    public static function Test()
    {
        ProgressData.data.slave_count = 1;
        for (i in 0...50)
        {
            trace(getLore());
            ProgressData.data.slave_count += 1;
        }
    }
}
