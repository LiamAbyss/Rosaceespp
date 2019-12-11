# Documentation

## Les types de variables

- chaines de caractères
- nombres
- booléens
- fonctions
- tableaux
- règles

## Déclarer une variable

### Chaines de caractères
``` chaine = "ma chaine" ```

### Nombres
``` nombre = 52 ```

``` nombre = 3.1415 ```

### Booléens
``` bool = vrai ```

``` bool = faux ```

### Fonctions
``` maFonction = fonction(param1, ..., paramN): ```

```    //Programme ```

``` fin ```

Les variables sont locales à l'intérieur d'une fonction ou du fichier principal sauf les fonctions qui sont héréditaires.

Une fonction peut retourner une valeur ou non.

### Tableaux
``` ajoute element à monTableau ```

Ici, ``` element ``` est une valeur ou une variable de n'importe quel type.

### Règles
``` regle = chaineClé::chaine ```

``` regle = chaineClé::nombre ```

#### Exemple :

``` chaine = "bnjur" ```

``` regle =  "o"::"b"::"j"```

``` chaine = chaine * regle  //chaine vaut maintenant "bonjour"```

``` chaine = chaine / regle  //chaine vaut maintenant "oonoour"```

</br></br>

## Les opérateurs

- L'opérateur ```+``` ou ```ou``` (compatible avec tous les types sauf fonction et tableau)
- L'opérateur ```-``` (compatible avec les types chaine, nombre, booléen)
- L'opérateur ```*``` ou ```et``` (compatible avec tous les types sauf fonction et tableau)
- L'opérateur ```/``` (compatible avec tous les types sauf fonction et tableau)
- L'opérateur ```::``` (compatible avec les chaines et les nombres pour la formation de règles)
- L'opérateur ```[]``` (prend un nombre et sert à récupérer un élément d'un tableau ou d'une chaine)

</br></br>

## Appeler une fonction

```maFonction(argument1, ..., argumentN)```

</br></br>

## Les instructions de contrôle

### Les comparaisons

Les comparaisons supportées sont ```==```, ```!=```, ```<```, ```>```, ```<=```, ```=>```.

### Les conditions

```si condition1 ou condition2 et condition3 :```

```    //Programme```

```sinon si condition 4 :```

```    //Programme```

```sinon :```

```    //Programme```

```fin```

### Les boucles

```pour var = nDebut:nFin(pas) :```

```    //Programme```

```fin```
</br></br>

```a = "a"```

```tant que a != "aaaa" :```

```    //Programme```

```    a = a + "a"```

```fin```

</br></br>

## Les entrées/sorties

Exemples d'entrées :

```demande var1```

```demande var1 avec sha256```

```mot de passe var2```

```mot de passe var2 sans sha256```

Sortie :

```affiche var1```

Note : Si la variable à afficher est d'un type différent de chaine, nombre ou booléen, le programme affichera ```<TYPE>::nomVar```.

</br></br>

## Manipulation de fichiers

### Ouvrir un fichier

```f = fichier(nomFichier, mode)```

Les modes d'ouvertures sont les mêmes qu'en langage C.

### Ecrire dans un fichier

```écrire var dans f```

### Lire depuis un fichier

```lire f //Lis caractère par caractère```

Exemple :

```caractere = lire f```

### Supprimer un fichier

```supprimer nomFichier```

### Renommer un fichier

```renommer nomFichier1 en nomFichier2```

</br></br>

## Chiffrement

```chiffrer chaine avec mdp```

```déchiffrer chaineChiffrée avec mdp```

</br></br>

## Les autres fonctions natives

```retourner``` 

```    /*Dans une fonction (non obligatoire) - Suivi ou non d'une variable à retourner*/``` 


```nettoie console //Porte bien son nom``` 

```pause //Elle aussi``` 

</br></br>

## L'inclusion d'autres fichiers

Au début d'un fichier uniquement :

```importe "nomFichier.rpp"```



