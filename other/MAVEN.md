## apache maven

### Help для pluginа

```
mvn help:describe -DgroupId=org.somewhere -DartifactId=some-plugin -Dversion=0.0.0
```

Краткая форма по названию плугина:

```
mvn help:describe -Dplugin=some-plugin
```

Примеры:

```
mvn help:describe -Ddetail=true -DgroupId=org.apache.maven.plugins -DartifactId=maven-help-plugin -Dversion=LATEST -Dgoal=describe

mvn help:describe -Dplugin=help
```

### Зависимости

```
mvn help:describe -DgroupId=org.apache.maven.plugins -DartifactId=maven-dependency-plugin -Dversion=LATEST
```

| cmd                                                          | Описание                                     |
| ------------------------------------------------------------ | -------------------------------------------- |
| `mvn dependency:list`                                        | Список зависимостей                          |
| `mvn dependency:tree`                                        | Дерево зависимостей                          |
| `mvn dependency:tree -DoutputType=dot -DoutputFile=test.dot` | Дерево зависимостей в DOT (graphviz) формате |

### Создание приложения из шаблона

```
mvn archetype:generate -DarchetypeGroupId=org.apache.maven.archetypes -DarchetypeArtifactId=maven-archetype-simple -DgroupId=com.example -DartifactId=test -Dversion=1.0-SNAPSHOT -DinteractiveMode=false
```

### Запуск приложения

```
mvn exec:java -Dexec.mainClass=com.example.App
mvn exec:java -Dexec.mainClass=com.example.App -Dexec.args=arg
```