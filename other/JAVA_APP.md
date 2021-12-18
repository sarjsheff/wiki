# Приложение на java с нуля

Создаем новый проект из стандартного шаблона (archetype) при помощи maven.

```
mvn archetype:generate -DarchetypeGroupId=org.apache.maven.archetypes -DarchetypeArtifactId=maven-archetype-simple -DgroupId=com.example -DartifactId=test -Dversion=1.0-SNAPSHOT -DinteractiveMode=false
```

В папке test будет создан наш проект. Исходный код сгенерированного приложения находится в файле ```src/main/java/com/example/App.java```. 

## Сборка

Собираем наше приложение в архив jar:

```
mvn clean package
```

## Запуск

В папке ```target``` должен появится архив ```test-1.0-SNAPSHOT.jar``` с нашим приложением, запускаем:

```
java -cp target/test-1.0-SNAPSHOT.jar com.example.App
```

можно запустить при помощи maven без предварительной сборки архива:

```
mvn exec:java -Dexec.mainClass=com.example.App
```

с принудительной чисткой и пересборкой:

```
mvn clean package exec:java -Dexec.mainClass=com.example.App
```

## Исходник

Исходный файл нашего приложения ```src/main/java/com/example/App.java```:

```
package com.example;

/**
 * Hello world!
 *
 */
public class App 
{
    public static void main( String[] args )
    {
        System.out.println( "Hello World!" );
    }
}
```

```package com.example;``` - пакет, должен соответствовать пути по которому расположен файл с исходным кодом ```com/example```.

Комментарий, между ```/*``` и ```*/``` может располагаться все что угодно:

```
/**
 * Hello world!
 *
 */
```

```public class App``` - класс, наименование должно соответствовать имени файла с исходным кодом ```App.java```.

```public static void main( String[] args )``` - метод main класса App, в методах содержится последовательность действий для нашего приложения, этот метод вызывается при запуске приложения. 

```String[] args``` - параметр args метода main, параметр args содержит массив аргументов переданных при запуске программы.

```System.out.println( "Hello World!" );``` - выведет ```"Hello World!"``` на экран.


## Приложение для вывод списка файлов в директории

Напишем приложение для вывода списка файлов из указанной директории. Путь до директории передается первым аргументом приложения ```java -cp target/test-1.0-SNAPSHOT.jar com.example.App /tmp```. Проверим передан ли аргумент и выведем его на экран, для этого изменяем ```src/main/java/com/example/App.java```:

```
package com.example;

public class App {
    public static void main(String[] args) {
        if (args.length > 0) {
            System.out.println(args[0]);
        } else {
            System.out.println("Укажите путь до директории.");
        }
    }
}
```

Собираем:

```
mvn clean package
```

Запускаем без аргументов:

```
java -cp target/test-1.0-SNAPSHOT.jar com.example.App
```

Запускаем с аргументом:

```
java -cp target/test-1.0-SNAPSHOT.jar com.example.App /tmp
```

Или одной командой собираем и запускаем:

```
mvn clean package exec:java -Dexec.mainClass=com.example.App -Dexec.args=/tmp
```

По указанному путь должна располагаться директория с доступом на чтение. Проверяем это:

```
package com.example;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class App {
    public static void main(String[] args) {
        if (args.length > 0) {
            Path dir = Paths.get(args[0]);
            if (Files.exists(dir) && Files.isDirectory(dir) && Files.isReadable(dir)) {
                System.out.println(String.format("Директория: %s", dir));
            } else {
                System.out.println(String.format("Директория не найдена: %s", dir));
            }
        } else {
            System.out.println("Укажите путь до директории.");
        }
    }
}
```

Выводим список файлов и директорий:

```
package com.example;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Iterator;
import java.util.stream.Stream;

public class App {
    public static void main(String[] args) {
        if (args.length > 0) {
            Path dir = Paths.get(args[0]);
            if (Files.exists(dir) && Files.isDirectory(dir) && Files.isReadable(dir)) {
                System.out.println(String.format("Директория: %s", dir));
                try {                                               // Начало блока проверки на ошибку
                    Stream<Path> files = Files.list(dir);           // Получаем список файлов
                    Iterator<Path> it = files.iterator();           // Получаем из списка файлов, итератор для обхода в цикле
                    while (it.hasNext()) {                          // Цикл выполняется пока в итераторе осталось хотя бы одно значение
                        Path file = it.next();                      // Забираем из итератора следующий файл
                        System.out.println(file.getFileName());     // Выводим имя файла
                    }
                    files.close();                                  // Закрываем список
                } catch (IOException e) {                           // Проверяем на возникновение ошибки
                    e.printStackTrace();                            // Если ошибка возникла выводим информацию о ней
                }
            } else {
                System.out.println(String.format("Директория не найдена: %s", dir));
            }
        } else {
            System.out.println("Укажите путь до директории.");
        }
    }
}
```
